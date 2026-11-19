#!/usr/bin/python3
"""Check that Brave Origin starts sandboxed, on the guest of boot-smoke.sh.

Brave Origin ignores headless commands like --dump-dom, so this reads
brave://sandbox through the DevTools protocol on --remote-debugging-pipe
instead. It prints the page text and exits 0 if Brave reports that it is
adequately sandboxed.
"""

import fcntl
import json
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time

URL = "chrome://sandbox"
EXPECTED = "You are adequately sandboxed."
TIMEOUT = 90


class Pipe:
    def __init__(self, write_fd, read_fd):
        self.write_fd = write_fd
        self.read_fd = read_fd
        self.buffer = b""
        self.next_id = 0

    def call(self, method, session=None, **params):
        self.next_id += 1
        message = {"id": self.next_id, "method": method, "params": params}
        if session:
            message["sessionId"] = session
        os.write(self.write_fd, json.dumps(message).encode() + b"\0")
        while True:
            reply = self.receive()
            if reply.get("id") == self.next_id:
                if "error" in reply:
                    raise RuntimeError(f"{method}: {reply['error']}")
                return reply["result"]

    def receive(self):
        while b"\0" not in self.buffer:
            chunk = os.read(self.read_fd, 65536)
            if not chunk:
                raise RuntimeError("Brave closed the DevTools pipe")
            self.buffer += chunk
        message, self.buffer = self.buffer.split(b"\0", 1)
        return json.loads(message)


def sandbox_text(pipe, state):
    if "session" not in state:
        # Brave ignores URLs on its command line here and opens a new tab page.
        target = pipe.call("Target.createTarget", url=URL)["targetId"]
        state["session"] = pipe.call("Target.attachToTarget", targetId=target, flatten=True)["sessionId"]
    try:
        result = pipe.call("Runtime.evaluate", state["session"],
                           expression="document.body ? document.body.innerText : ''", returnByValue=True)
    except RuntimeError:
        # The page is still loading.
        return ""
    return result["result"].get("value", "")


def stop_processes(work):
    """Stop every process started from the scratch directory, helpers included."""
    marker = work.encode()
    for sig in (signal.SIGTERM, signal.SIGKILL):
        deadline = time.monotonic() + 10
        while True:
            pids = []
            for entry in os.listdir("/proc"):
                if not entry.isdigit() or int(entry) == os.getpid():
                    continue
                try:
                    with open(f"/proc/{entry}/cmdline", "rb") as f:
                        if marker in f.read():
                            pids.append(int(entry))
                except OSError:
                    pass
            if not pids:
                return
            for pid in pids:
                try:
                    os.kill(pid, sig)
                except ProcessLookupError:
                    pass
            if time.monotonic() >= deadline:
                break
            time.sleep(0.5)


def main():
    work = tempfile.mkdtemp(prefix="brave-sandbox-")
    profile = os.path.join(work, "profile")
    os.mkdir(profile)
    os.mkdir(os.path.join(work, "tmp"))
    # Brave Origin asks on first start whether to buy it or use the free tier,
    # and waits there forever without a display. Linux offers the free tier, so
    # accept it up front.
    with open(os.path.join(profile, "Local State"), "w") as f:
        json.dump({"brave": {"origin": {"free_tier_accepted": True}}}, f)

    brave_reads, to_brave = os.pipe()
    from_brave, brave_writes = os.pipe()

    def child_fds():
        # Chromium reads DevTools commands from fd 3 and answers on fd 4. Move
        # both ends clear of 3 and 4 first: dup2 onto the same fd would keep it
        # close-on-exec.
        reads = fcntl.fcntl(brave_reads, fcntl.F_DUPFD, 10)
        writes = fcntl.fcntl(brave_writes, fcntl.F_DUPFD, 10)
        os.dup2(reads, 3)
        os.dup2(writes, 4)

    text = ""
    try:
        subprocess.Popen(
            ["brave-origin-stable", "--headless", "--disable-gpu", "--no-first-run",
             "--password-store=basic", "--allow-chrome-scheme-url", "--remote-debugging-pipe",
             f"--user-data-dir={profile}"],
            stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=sys.stderr,
            env={**os.environ, "TMPDIR": os.path.join(work, "tmp")},
            preexec_fn=child_fds, close_fds=False, start_new_session=True,
        )
        os.close(brave_reads)
        os.close(brave_writes)
        signal.signal(signal.SIGALRM, lambda *_: (_ for _ in ()).throw(TimeoutError()))
        signal.alarm(TIMEOUT)
        pipe = Pipe(to_brave, from_brave)
        state = {}
        while EXPECTED not in text:
            text = sandbox_text(pipe, state)
            if EXPECTED not in text:
                time.sleep(1)
        signal.alarm(0)
        pipe.call("Browser.close")
    except TimeoutError:
        print(f"Brave didn't report {EXPECTED!r} within {TIMEOUT}s", file=sys.stderr)
    except RuntimeError as e:
        print(f"DevTools error: {e}", file=sys.stderr)
    finally:
        signal.alarm(0)
        stop_processes(work)
        shutil.rmtree(work, ignore_errors=True)

    print(text)
    return 0 if EXPECTED in text else 1


if __name__ == "__main__":
    sys.exit(main())

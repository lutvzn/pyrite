#!/usr/bin/env bash

# RPM compares the epoch, version and release separately. Missing epochs are 0.
brave_compare() {
    local result
    result=$(BRAVE_LEFT="$1" BRAVE_RIGHT="$2" rpm --eval '%{lua:
        local function parse(name)
            local evr = os.getenv(name)
            local epoch, vr = evr:match("^([0-9]+):(.+)$")
            local version, release = (vr or evr):match("^([^%s:%-]+)%-([^%s:%-]+)$")
            assert(version, "Invalid RPM EVR: " .. evr)
            return tonumber(epoch or "0"), version, release
        end
        local ae, av, ar = parse("BRAVE_LEFT")
        local be, bv, br = parse("BRAVE_RIGHT")
        local result = ae > be and 1 or (ae < be and -1 or rpm.vercmp(av, bv))
        if result == 0 then result = rpm.vercmp(ar, br) end
        print(result > 0 and 1 or (result < 0 and -1 or 0))
    }') || return
    case "$result" in
        -1|0|1) printf '%s\n' "$result" ;;
        *) echo 'RPM EVR comparison failed' >&2; return 1 ;;
    esac
}

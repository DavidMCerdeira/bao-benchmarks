#!/usr/bin/env bash
set -euo pipefail

PLATFORM="rh850-u2a16"
DEVICE="RH850/U2x"
TOOL="e2"
OSC_MHZ="40.0"
RFP_PASS="ffff"

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage:
  ${SCRIPT_NAME} ctx-switch
  ${SCRIPT_NAME} irq-lat [guest|native]
  ${SCRIPT_NAME} irq-lat-wce

Examples:
  ${SCRIPT_NAME} ctx-switch
  ${SCRIPT_NAME} irq-lat guest
  ${SCRIPT_NAME} irq-lat native
  ${SCRIPT_NAME} irq-lat-wce

Notes:
  - Guest scenarios flash one or more guest HEX images, then build+run Bao.
  - Native scenario flashes the native HEX and runs without Bao.
EOF
}

BENCHMARK="${1:-}"
MODE="${2:-}"  # only meaningful for irq-lat: guest|native

if [[ -z "${BENCHMARK}" ]]; then
  usage
  exit 2
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}"

die() { echo "error: $*" >&2; usage >&2; exit 2; }

flash_hex() {
  local f="$1"
  if [[ -s "$f" ]]; then
    echo "Flashing: $f"
    echo "${RFP_PASS}" | rfp-cli -device "${DEVICE}" -tool "${TOOL}" -osc "${OSC_MHZ}" \
      -program -file "$f"
  else
    die "HEX not found or empty: $f"
  fi
}

run_bao() {
  make -C src/bao-hypervisor clean
  make -C src/bao-hypervisor PLATFORM="${PLATFORM}" CONFIG_REPO="${ROOT_DIR}/configs/${PLATFORM}" CONFIG=benchmark DEBUG=n
  echo "${RFP_PASS}" | rfp-cli -device "${DEVICE}" -tool "${TOOL}" -osc "${OSC_MHZ}" \
    -program -bin 0x0 "src/bao-hypervisor/bin/${PLATFORM}/benchmark/bao.bin" -run
}

flash_and_run_native_hex() {
  local f="$1"
  if [[ -s "$f" ]]; then
    echo "Flashing (native): $f"
    echo "${RFP_PASS}" | rfp-cli -device "${DEVICE}" -tool "${TOOL}" -osc "${OSC_MHZ}" \
      -program -file "$f" -run
  else
    die "HEX not found or empty: $f"
  fi
}

hex_path() {
  local b="$1"
  local v="$2"
  echo "${ROOT_DIR}/src/${b}/${v}/build/${v}/${v}.hex"
}

# Validate args early (before building)
case "${BENCHMARK}" in
  ctx-switch|irq-lat|irq-lat-wce) ;;
  -h|--help|help) usage; exit 0 ;;
  *) die "unknown benchmark: '${BENCHMARK}'" ;;
esac

if [[ "${BENCHMARK}" != "irq-lat" && -n "${MODE}" ]]; then
  die "mode argument is only valid for 'irq-lat' (guest|native)"
fi

if [[ "${BENCHMARK}" == "irq-lat" && -n "${MODE}" && "${MODE}" != "guest" && "${MODE}" != "native" ]]; then
  die "unknown mode for irq-lat: '${MODE}' (expected: guest|native)"
fi



make clean
# Build benchmark(s)
make -C "${ROOT_DIR}" "${BENCHMARK}" PLATFORM="${PLATFORM}"


# Run scenario
case "${BENCHMARK}" in
  ctx-switch)
    flash_hex "$(hex_path "${BENCHMARK}" "${BENCHMARK}-guest1")"
    flash_hex "$(hex_path "${BENCHMARK}" "${BENCHMARK}-guest2")"
    run_bao
    ;;

  irq-lat)
    [[ -z "${MODE}" ]] && MODE="guest"
    if [[ "${MODE}" == "guest" ]]; then
      flash_hex "$(hex_path "${BENCHMARK}" "${BENCHMARK}-guest")"
      run_bao
    else
      flash_and_run_native_hex "$(hex_path "${BENCHMARK}" "${BENCHMARK}-native")"
    fi
    ;;

  irq-lat-wce)
    flash_hex "$(hex_path "${BENCHMARK}" "${BENCHMARK}-guest1")"
    flash_hex "$(hex_path "${BENCHMARK}" "${BENCHMARK}-guest2")"
    run_bao
    ;;
esac


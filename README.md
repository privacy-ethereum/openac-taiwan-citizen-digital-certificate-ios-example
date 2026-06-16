# OpenAC Taiwan Citizen Digital Certificate iOS Example

<p align="center">
<a href="https://testflight.apple.com/join/UuVzqwHk"><img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"
alt="Demo of the Nextcloud iOS files app"
height="40"></a>
</p>

An iOS example app that integrates Taiwan's Citizen Digital Certificate ([TW FidO](https://fido.moi.gov.tw/pt/)) with [openac-rsa-x509-swift](https://github.com/privacy-ethereum/openac-rsa-x509-swift) to generate a zero-knowledge proof from the certificate signature and send it to a server for verification.

## Demo

|                       Download Circuits                       |                Sign with MOICA                 |                 Generate Proof                 |
| :-----------------------------------------------------------: | :--------------------------------------------: | :--------------------------------------------: |
| ![Download circuits](images/openac-ios-download-circuits.gif) | ![Sign with MOICA](images/openac-ios-sign.gif) | ![Generate proof](images/openac-ios-prove.gif) |
|                          ~10 seconds                          |                  ~11 seconds                   |           prove ~5 s \| verify ~13 s           |

### Setup Card

Always visible. Shows download progress for the files below (shown only when not yet present); the MOICA and ZK Pipeline sections are hidden until all three are ready.

- **Download Circuit** — fetches and decompresses `cert_chain_rs4096_proving.key`, `user_sig_rs2048_proving.key` (zkID releases), and `g3-tree-snapshot.json.gz` (moica-revocation-smt releases)

### TW FidO / MOICA Card _(visible after circuit + keys are ready)_

Enter your **ID Number** (身分證字號), then follow the steps:

- **TBS** — to-be-signed challenge bytes; tap the refresh button to call `POST /challenge` on the server and receive a `challenge_bytes`
- **Get SP Ticket** — calls `POST /fido/sp-ticket` with the ID number and TBS; returns a signed `sp_ticket`
- **Verify with MOICA** — deep-links to `mobilemoica://moica.moi.gov.tw/a2a/verifySign` so the MOICA app performs the signature; returns to `openac://callback`
- **Auth Result** — calls `POST /fido/ath-result`, polling until the signed response and signer certificate are available
- **Generate Input** — calls `generateCertChainRs4096Input` from `openac-rsa-x509-swift` to build the circuit input JSON from the MOICA response, issuer certificate, TBS, and SMT snapshot

### ZK Pipeline Card _(visible after circuit + keys are ready)_

- **Generate Proof** — runs `proveCertChainRs4096` and `proveUserSigRs2048` (Groth16 provers); reports time in ms
- **Verify** — submits proofs to `POST /link-verify` with the challenge ID and cert chain type (`rs4096`)
- **Run All Steps** — convenience button in the toolbar that runs prove + verify in sequence

### Link-verify request format

```json
{
    "cert_chain_type": "rs4096",
    "cert_chain_proof": "<base64-encoded bytes>",
    "user_sig_proof": "<base64-encoded bytes>"
}
```

## Getting Started

Clone the repo and open it in Xcode.

```bash
git clone https://github.com/privacy-ethereum/openac-taiwan-citizen-digital-certificate-ios-example
```

### 1. Start the verifier server

Clone and run [go-zkid-verifier](https://github.com/privacy-ethereum/go-zkid-verifier), then expose it via [ngrok](https://ngrok.com):

```bash
# In the go-zkid-verifier directory
make download-keys
make build
make serve
```

```bash
# In a separate terminal
ngrok http 8080
```

ngrok will print a public URL like `https://b33f-54-237-15-198.ngrok-free.app`. Copy it.

### 2. Update the server URLs in the app

Open `OpenACExampleApp/ProofViewModel.swift` and replace the two URL constants near the top of the file with your ngrok URL:

```swift
private let serverURL = URL(string: "https://<your-subdomain>.ngrok-free.app/challenge")!
private let linkVerifyURL = URL(string: "https://<your-subdomain>.ngrok-free.app/link-verify")!
```

### 3. Configuration — `Secrets.swift`

The app requires TW FidO SP service credentials. Apply for these as an SP (Service Provider) at [https://fido.moi.gov.tw/pt/](https://fido.moi.gov.tw/pt/), then create or update the file below **before building** (it is git-ignored):

```
OpenACExampleApp/Secrets.swift
```

```swift
enum Secrets {
    static let fidoSpServiceID = "your-sp-service-id"
    static let fidoAESKey      = "your-32-byte-aes-key-base64"
}
```

| Constant          | Description                                                                        |
| ----------------- | ---------------------------------------------------------------------------------- |
| `fidoSpServiceID` | SP service ID issued by MOICA for TW FidO                                          |
| `fidoAESKey`      | 32-byte AES-256 key (base64-encoded) used to compute `sp_checksum` via AES-256-GCM |

Credentials can also be supplied at test time via environment variables `FIDO_SP_SERVICE_ID` and `FIDO_AES_KEY`; the app falls back to `Secrets.swift` if those are absent.

### 4. Build and run

1. Open `OpenACExampleApp.xcodeproj` in Xcode (`open . -a Xcode`).
2. Select a physical iPhone and ensure the [TW FidO app (行動自然人憑證)](https://apps.apple.com/tw/app/%E8%A1%8C%E5%8B%95%E8%87%AA%E7%84%B6%E4%BA%BA%E6%86%91%E8%AD%89/id1462866416) is installed.
3. Build and run.
4. On first launch, tap **Download Circuit** in the Setup section and wait for all three files to download.
5. Tap the refresh button next to **TBS** to fetch a challenge from the server.
6. Enter your ID number (身分證字號), then follow the TW FidO / MOICA steps in order.
7. Tap **Run All Steps** (or individual play buttons) to generate and verify the ZK proofs.

## Requirements

- iOS 16+
- Xcode 15+
- MOICA app installed on device for the authentication flow
- A running server exposing `/challenge` and `/link-verify` endpoints

## Dependencies

- [openac-rsa-x509-swift](https://github.com/privacy-ethereum/openac-rsa-x509-swift) — Swift bindings for `proveCertChainRs4096`, `proveUserSigRs2048`, `verifyCertChainRs4096`, `verifyUserSigRs2048`, `generateCertChainRs4096Input`
- CryptoKit (system) — AES-256-GCM for the sp_checksum required by the TW FidO API
- zlib (system) — decompresses `.gz` key files on-device

## See also

- [openac-rsa-x509-swift](https://github.com/privacy-ethereum/openac-rsa-x509-swift) — API, installation, and prebuilt binaries
- [zkID releases](https://github.com/privacy-ethereum/zkID/releases/tag/RSA-X.509-Cert-latest) — circuit and key files
- [moica-revocation-smt](https://github.com/privacy-ethereum/moica-revocation-smt) — SMT snapshot releases

## Community

- X account: <a href="https://twitter.com/zkmopro"><img src="https://img.shields.io/twitter/follow/zkmopro?style=flat-square&logo=x&label=zkmopro"></a>
- Telegram group: <a href="https://t.me/zkmopro"><img src="https://img.shields.io/badge/telegram-@zkmopro-blue.svg?style=flat-square&logo=telegram"></a>

## Acknowledgements

It is currently incubated by [PSE](https://pse.dev/).

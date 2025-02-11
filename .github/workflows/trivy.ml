name: trivy
on:
  schedule:
    - cron: "00 8 * * *" # build at 8:00 UTC every day 

  push:
    branches:
      - live

  workflow_dispatch: # allow manually triggering builds
jobs:
  build:
    name: Trivy
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      - name: Checkout code
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@915b19bbe73b92a6cf82a1bc12b087c9a19a5fe2 # v0.28.0
        with:
          image-ref: 'ghcr.io/wayblueorg/hyprland:latest'
          format: template
          scanners: vuln,secret,misconfig
          template: '@/contrib/sarif.tpl'
          output: trivy-results.sarif
          timeout: 30m0s
          skip-dirs: "/sysroot/ostree"
        env:
          TRIVY_DB_REPOSITORY: ghcr.io/aquasecurity/trivy-db,public.ecr.aws/aquasecurity/trivy-db
          TRIVY_JAVA_DB_REPOSITORY: ghcr.io/aquasecurity/trivy-java-db,public.ecr.aws/aquasecurity/trivy-java-db
      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@4f3212b61783c3c68e8309a0f18a699764811cda # v3.27.1
        with:
          sarif_file: trivy-results.sarif
      - uses: actions/upload-artifact@b4b15b8c7c6ac21ea08fcf65892d2ee8f75cf882 # v4.4.3
        with:
          name: Trivy scan SARIF
          path: trivy-results.sarif
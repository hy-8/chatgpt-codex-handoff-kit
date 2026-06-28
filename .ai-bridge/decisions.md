# Decisions

- Use CodexPro handoff mode for the first test so ChatGPT writes plans without directly editing source files.
- Use safe bash mode so ChatGPT can run focused verification commands through CodexPro without arbitrary shell access.
- Use Cloudflare quick tunnel for the first test because it is the fastest public HTTPS setup.
- Use local port 8788 because 8787 is already in use on this machine.
- Use the locally installed `cloudflared.exe` in `C:\Users\ASUS\.codexpro\bin` to avoid CodexPro's auto-download hanging on this network.

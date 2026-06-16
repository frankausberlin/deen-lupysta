## Vast.AI, LocalAI & OpenLIT

### LocalAI

#### Self-Hosted Installation as a systemd User Service

By default, we run LocalAI on the host machine using a statically linked AMD64 binary running under systemd on user-space level (`systemctl --user`). This allows isolated execution, GPU acceleration, and simple port forwarding.

* **Working Directory:** `~/.localai`
* **Port:** `9090` (Bound publicly to support Docker bridges like LiteLLM/Open WebUI)
* **Binary Location:** `~/.localai/locai`

##### 1. Systemd User Service Configuration
Create the unit file at `~/.config/systemd/user/localai.service`:

```ini
[Unit]
Description=LocalAI Server
After=network.target

[Service]
# Forces LocalAI to run and store assets within this directory
WorkingDirectory=%h/.localai

# Pre-heat folders
ExecStartPre=/usr/bin/mkdir -p %h/.localai/models %h/.localai/backends %h/.localai/data %h/.localai/configuration

# Start Command (Modern versions >= v4.2.x require public bind validation)
ExecStart=%h/.localai/locai run --address :9090 --allow-insecure-public-bind

Restart=always
RestartSec=5

[Install]
WantedBy=default.target
```

##### 2. Start and Enable Service
```shell
# Reload user daemon and start service
systemctl --user daemon-reload
systemctl --user enable --now localai.service

# Restart service
systemctl --user restart localai

# Check service status
systemctl --user status localai.service --no-pager

# Follow system logs
journalctl --user -u localai -f
```



---

#### Security Pitfall in v4.2.x+ (Public Bind Option)
> ⚠️ **Important Security Note for LocalAI v4.2+**
> Recent versions of LocalAI enforce security standards that block public address bindings (like `:9090` or `0.0.0.0:9090`) unless authentication is present. Since your Docker instances (e.g. Open WebUI, LiteLLM) require connecting to the host machine's port, you must either:
> 1. Specify an API key / credentials, OR
> 2. Pass the **`--allow-insecure-public-bind`** flag inside `ExecStart` to let the LocalAI API start on `:9090` without authentication.
> Failing to set this flag will result in a service crash with `exit-code` and status `1/FAILURE` during startup.

---

#### Standard Update Procedure (Manual)

To manually update the standalone LocalAI installation to a custom or newer version (for example, `v4.2.6`), perform the following steps:

```shell
# 1. Stop the active user service
systemctl --user stop localai.service

# 2. Navigate to directory & back up current binary
cd ~/.localai && mv locai locai.bak

# 3. Download the target release (AMD64 Linux Binary)
wget -O locai https://github.com/mudler/LocalAI/releases/download/v4.2.6/local-ai-v4.2.6-linux-amd64

# 4. Make it executable
chmod +x locai

# 5. Start and test the service
systemctl --user start localai.service
systemctl --user status localai.service --no-pager
```

#### The Model Modders on Hugging Face

*mradermacher, bartowski & co.*

There's a scene on Hugging Face where model modders create usable versions of the original models using quantization.

The Q parameter
* During quantization, weights are compressed (e.g., Q8, Q4, Q2). With each quantization level, the model becomes smaller but also loses some nuances ("becomes dumber").

The K-quant parameter
* The appendages _K_S, _K_M, and _K_L describe that the quantization is not applied uniformly to the entire model. Instead, critical, quality-determining layers are kept at higher precision (less compressed). A distinction is made here between Small, Medium, and Large.

The i1 parameter (Importance Matrix)
* A newer, clever procedure (I-Quants) where a preliminary analysis with a calibration dataset determines which weights are vital (and compressed less) and which ones can be compressed significantly.


---

*(🚧 Work In Progress / Under Construction)*

There should be descriptions here unterm other topics:

* **using LocalAI for TTS/STT with Open WebUI**
* **using LocalAI on vast.ai**
* **vast.ai config decision tree**
* **using the vast.ai CLI tool**
* **setup, tips, configuration**
* **example: deepseek-v4-fast (openweights model)**

---

### OpenLIT

OpenLIT is used for monitoring LLM and GPU metrics.

* Official Repository: [https://github.com/openlit/openlit](https://github.com/openlit/openlit)
* Further configuration guides are under construction.

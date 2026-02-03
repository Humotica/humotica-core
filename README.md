# humotica-core

**The Complete AI Provenance Stack**

Docker image with tibet-core + did-jis-core, ready for enterprise deployment.

## Quick Start

```bash
# Pull from Docker Hub
docker pull humotica/core

# Run interactive Python
docker run -it humotica/core

# Inside container:
>>> from tibet_core import TibetEngine
>>> from did_jis_core import DIDEngine
>>>
>>> did = DIDEngine()
>>> tibet = TibetEngine()
>>>
>>> identity = did.create_did("my-service")
>>> token = tibet.create_token("action", "Processing request", [], "{}", "User request", identity)
>>> print(token.id)
```

## What's Included

| Component | Description |
|-----------|-------------|
| `tibet-core` | TIBET provenance engine (Python + C) |
| `did-jis-core` | DID:JIS identity engine (Python + C) |
| `libtibet_core.so` | C library for embedded integration |
| `libdid_jis_core.so` | C library for embedded integration |
| `tibet.h` | C header for tibet-core |
| `did_jis.h` | C header for did-jis-core |

## For Enterprise Architects

### Docker Compose

```yaml
services:
  provenance-api:
    image: humotica/core
    ports:
      - "8080:8080"
    volumes:
      - ./app:/app
    command: python3 /app/main.py
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: provenance-service
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: provenance
        image: humotica/core:latest
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

## For Hardware Engineers (C Integration)

```c
#include <tibet.h>
#include <did_jis.h>

int main() {
    // Create identity
    did_engine_t* did = did_engine_new();
    char* identity = did_create(did, "device:001");

    // Create provenance
    tibet_engine_t* tibet = tibet_engine_new();
    char* token = tibet_create_token(
        tibet, "sensor", "reading", "[]", "{}",
        "Periodic sensor data", identity, NULL
    );

    // Send to cloud...

    tibet_free_string(token);
    did_free_string(identity);
    tibet_engine_free(tibet);
    did_engine_free(did);
    return 0;
}
```

Compile with:
```bash
gcc -o app app.c -ltibet_core -ldid_jis_core
```

## Build Locally

```bash
git clone https://github.com/Humotica/humotica-core.git
cd humotica-core
docker build -t humotica/core .
```

## Links

- **Docker Hub**: https://hub.docker.com/r/humotica/core
- **tibet-core**: https://github.com/Humotica/tibet-core
- **did-jis-core**: https://github.com/Humotica/did-jis-core
- **PyPI (tibet)**: https://pypi.org/project/tibet-core/
- **PyPI (did)**: https://pypi.org/project/did-jis-core/
- **npm (tibet)**: https://www.npmjs.com/package/tibet-core
- **npm (did)**: https://www.npmjs.com/package/did-jis-core

## IETF Drafts

- [TIBET: Evidence Trail Protocol](https://datatracker.ietf.org/doc/draft-vandemeent-tibet-provenance/)
- [JIS: Identity Standard](https://datatracker.ietf.org/doc/draft-vandemeent-jis-identity/)

## License

MIT OR Apache-2.0

---
*Built by Humotica - AI Provenance for Everyone*

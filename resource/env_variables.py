"""
Variable file untuk meng-inject credential dari file .env ke dalam Robot Framework.

Kenapa file ini dibuat:
- data/maker_checker_credentials.yaml sebelumnya menulis password sebagai
  string literal "${MAKER_PASSWORD_ENV}". Robot Framework TIDAK melakukan
  substitusi environment variable di dalam file YAML, sehingga nilai yang
  benar-benar terpakai adalah teks "${MAKER_PASSWORD_ENV}" itu sendiri
  (bukan isi .env). Ini bug: credential sensitif harus benar-benar dibaca
  dari environment (.env), bukan hardcode di yaml.
- File ini membaca .env (tanpa dependency tambahan seperti python-dotenv,
  supaya tidak menambah requirement baru) lalu mengekspos variable-nya ke
  Robot Framework lewat get_variables().

Cara pakai di suite:
    *** Settings ***
    Variables    ../../resource/env_variables.py
"""

import os

_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_ENV_PATH = os.path.join(_PROJECT_ROOT, ".env")


def _load_dot_env(path):
    """Parse file .env sederhana (KEY=VALUE per baris) tanpa dependency eksternal."""
    if not os.path.exists(path):
        return
    with open(path, encoding="utf-8") as env_file:
        for raw_line in env_file:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            # Jangan timpa environment variable yang sudah di-set manual
            # (misalnya lewat CI/CD secret), .env hanya sebagai fallback lokal.
            os.environ.setdefault(key, value)


_load_dot_env(_ENV_PATH)


def get_variables():
    required = [
        "MAKER_USERNAME",
        "MAKER_PASSWORD",
        "CHECKER_USERNAME",
        "CHECKER_PASSWORD",
    ]
    missing = [name for name in required if not os.environ.get(name)]
    if missing:
        raise ValueError(
            "Environment variable berikut tidak ditemukan (cek file .env): "
            + ", ".join(missing)
        )

    return {name: os.environ[name] for name in required}

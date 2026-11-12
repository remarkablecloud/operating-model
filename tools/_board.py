"""Shared by the board tools: the configuration and a gh wrapper."""
import json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))


def config():
    path = os.environ.get("OM_BOARD_CONFIG", os.path.join(HERE, "board.json"))
    if not os.path.exists(path):
        sys.exit(f"no board configuration at {path} (board-setup.sh writes it; see board.example.json)")
    with open(path) as f:
        return json.load(f)


def work_dir():
    d = os.environ.get("OM_WORK_DIR", os.path.join(HERE, ".work"))
    os.makedirs(d, exist_ok=True)
    return d


def gh(*args):
    r = subprocess.run(["gh", *args], capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"gh {' '.join(args[:3])} ... failed: {r.stderr.strip()}")
    return r.stdout


def project_id(cfg):
    return gh("project", "view", str(cfg["project_number"]), "--owner", cfg["owner"],
              "--format", "json", "--jq", ".id").strip()


def short(key, cfg):
    """owner/repo#12 shown as #12 for the default repo, repo#12 for the others."""
    repo, n = key.split("#")
    return f"#{n}" if repo == cfg.get("default_repo") else f"{repo.split('/')[-1]}#{n}"

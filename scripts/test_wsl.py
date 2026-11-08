#!/usr/bin/env python3
"""Host-independent checks; Windows programs are mocked, never launched."""
import base64
import json
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib
import unittest

REPO = Path(__file__).resolve().parents[1]


class WSLTests(unittest.TestCase):
    def test_config_parsing(self):
        for path in REPO.glob(".config/**/*.toml"):
            tomllib.loads(path.read_text())
        json.loads((REPO / ".config/fastfetch/config.jsonc").read_text())

    def test_installer_backup_and_repeat(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            (home / ".config/nvim").mkdir(parents=True)
            (home / ".config/nvim/personal").write_text("preserve me")
            (home / ".tmux.conf").write_text("old tmux")
            env = dict(os.environ, HOME=tmp)
            env.pop("XDG_CONFIG_HOME", None)
            command = ["bash", str(REPO / "scripts/install.sh")]
            subprocess.run(command, env=env, check=True, capture_output=True)
            backups = list((home / ".local/state/dotfiles-backups").iterdir())
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / ".config/nvim/personal").read_text(), "preserve me")
            self.assertEqual((backups[0] / ".tmux.conf").read_text(), "old tmux")
            self.assertEqual((home / ".config/nvim").resolve(), REPO / ".config/nvim")
            subprocess.run(command, env=env, check=True, capture_output=True)
            self.assertEqual(list((home / ".local/state/dotfiles-backups").iterdir()), backups)

    def mock_environment(self, root):
        root = Path(root)
        powershell = root / "powershell.exe"
        powershell.write_text(
            "#!/usr/bin/env python3\nimport os,sys,json\n"
            "from pathlib import Path\n"
            "Path(os.environ['CAPTURE']).write_text(json.dumps(sys.argv[1:]))\n"
            "if sys.argv[-1].endswith('ReadToEnd())'):\n"
            " Path(os.environ['PAYLOAD']).write_bytes(sys.stdin.buffer.read())\n"
            "else:\n sys.stdout.buffer.write('αβ 🧬\\nsecond line'.encode())\n"
        )
        powershell.chmod(0o755)
        wslpath = root / "wslpath"
        wslpath.write_text('#!/usr/bin/env python3\nimport sys\nprint("C:" + sys.argv[-1])\n')
        wslpath.chmod(0o755)
        return dict(os.environ, PATH=str(root) + os.pathsep + os.environ["PATH"],
                    CAPTURE=str(root / "args"), PAYLOAD=str(root / "payload"))

    def test_unicode_clipboard(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = self.mock_environment(tmp)
            data = "αβ 🧬\nsecond line".encode()
            bridge = str(REPO / ".local/bin/wsl-clipboard")
            subprocess.run([bridge, "copy"], input=data, env=env, check=True)
            self.assertEqual(Path(env["PAYLOAD"]).read_bytes(), data)
            result = subprocess.run([bridge, "paste"], env=env, capture_output=True, check=True)
            self.assertEqual(result.stdout, data)

    def test_open_keeps_paths_and_urls_as_data(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = self.mock_environment(tmp)
            file = Path(tmp) / "α space ' $(touch SHOULD_NOT_EXIST).pdf"
            file.touch()
            for target, expected in [(str(file), "C:" + str(file)),
                                     ("https://example.org/?q=';$x=1", "https://example.org/?q=';$x=1")]:
                subprocess.run([str(REPO / ".local/bin/wsl-open"), target], env=env,
                               check=True, capture_output=True)
                args = json.loads(Path(env["CAPTURE"]).read_text())
                script = base64.b64decode(args[-1]).decode("utf-16-le")
                encoded_target = script.split("FromBase64String('", 1)[1].split("')", 1)[0]
                self.assertEqual(base64.b64decode(encoded_target).decode(), expected)
                self.assertNotIn(expected, script)
            self.assertFalse((REPO / "SHOULD_NOT_EXIST").exists())


if __name__ == "__main__":
    unittest.main()

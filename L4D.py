
#!/usr/bin/env python3
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │                    @L4DXOP UNLIMITED LUA TOOL                              │
# │                         COMPLETE VERSION                                   │
# │                    DEVELOPER : @L4DXOP                                      │
# │                    OWNER   : L4DXOP                                         │
# │                    CREDIT  : @L4DXOP                            │
# │                    TOOL BY : @L4DXOP                            │
# └─────────────────────────────────────────────────────────────────────────────┘
# =============================================================================
#                    ⚡ POWERED BY @L4DXOP ⚡
#                    🔥 TOOL BY @L4DXOP 🔥
#                    💎 CREDIT @L4DXOP 💎
# =============================================================================

import os
import sys
import struct
import glob
import shutil
import subprocess
import time
import re
import tempfile
import colorsys
import math
import zlib
import base64
import itertools as it
import traceback
import random
import hashlib
import platform
import json
import uuid
import threading
from typing import Tuple, List, Optional, Dict, Any
from dataclasses import dataclass
from functools import lru_cache
from pathlib import PurePath, Path
from datetime import datetime
from collections import Counter

# ================== CREDIT CONSTANT ==================
CREDIT = "@L4DXOP"
TOOL_NAME = "@L4DXOP UNLIMITED LUA TOOL"

# ================== COLOR CONSTANTS ==================
R = "\033[0m"
BOLD = "\033[1m"
GRY = "\033[90m"
AC = "\033[36m"
TL = "\033[93m"
WH = "\033[37m"
DK = "\033[94m"
BD = "\033[91m"

# ================== SETUP ==================
def setup():
    os.system('cls' if os.name == 'nt' else 'clear')

# ═══════════════════════════════════════════════════════════════════════════════

if not hasattr(it, 'batched'):
    def batched(iterable, n):
        it_iter = iter(iterable)
        while True:
            chunk = list(it.islice(it_iter, n))
            if not chunk:
                break
            yield chunk
    it.batched = batched

# ── Optional PAK dependencies ─────────────────────────────────────────────

PAK_MODE_AVAILABLE = True
try:
    import gmalg
    try:
        from gmalg.base import BlockCipher
        from gmalg.errors import IncorrectLengthError
        from gmalg.utils import ROL32
    except ImportError:
        class BlockCipher: pass
        class IncorrectLengthError(Exception):
            def __init__(self, name, expected, actual):
                super().__init__(f"Incorrect length for {name}: expected {expected}, got {actual}")
        def ROL32(x, n): return ((x << n) & 0xFFFFFFFF) | (x >> (32 - n))
except ImportError:
    PAK_MODE_AVAILABLE = False
    class BlockCipher: pass
    class IncorrectLengthError(Exception):
        def __init__(self, name, expected, actual):
            super().__init__(f"Incorrect length for {name}: expected {expected}, got {actual}")
    def ROL32(x, n): return ((x << n) & 0xFFFFFFFF) | (x >> (32 - n))

try:
    from Crypto.Cipher import AES
    from Crypto.Cipher.AES import MODE_CBC
    from Crypto.Hash import SHA1
    from Crypto.Util.Padding import pad, unpad
except ImportError:
    PAK_MODE_AVAILABLE = False

try:
    from zstandard import ZstdDecompressor, ZstdCompressor, ZstdCompressionDict, DICT_TYPE_AUTO
except ImportError:
    PAK_MODE_AVAILABLE = False

# ==============================================================================
# L4DXOP UI - PROFESSIONAL  |  CREDIT: @L4DXOP
# ==============================================================================

RED = "#FF0055"
GREEN = "#00FF88"
BLUE = "#00AAFF"
GOLD = "#FFD700"
NEON = "#00FFAA"
ACCENT = "#FF6B6B"
MUTED = "#666666"
WARN = "#FFAA00"
SUCCESS = "#00FF88"
ERR = "#FF0055"
WHITE = "#FFFFFF"
CYAN = "#00CCFF"
MAGENTA = "#FF00FF"
PURPLE = "#AA44FF"

from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.box import ROUNDED, HEAVY, DOUBLE
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn, TimeElapsedColumn
from rich.prompt import Prompt, Confirm
from rich.syntax import Syntax
from rich.markdown import Markdown
from rich.text import Text
from rich import print as rprint

console = Console()

            
def safe_input(prompt: str = "") -> str:
    try:
        return input(prompt)
    except (KeyboardInterrupt, EOFError):
        return ""

def escape(text: str) -> str:
    return text.replace("[", "\\[").replace("]", "\\]")

class AnimatedBorder:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._start_time = time.time()
        return cls._instance

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls()
        return cls._instance

    def get_rainbow_color(self, offset=0, speed=1.0):
        t = time.time() * speed + offset
        r = int(abs(math.sin(t)) * 255)
        g = int(abs(math.sin(t + 2.094)) * 255)
        b = int(abs(math.sin(t + 4.188)) * 255)
        return f"#{r:02x}{g:02x}{b:02x}"

    def get_moving_border_style(self, position=0, speed=0.8):
        colors = ["#FF0055", "#FFAA00", "#00FF88", "#00AAFF", "#AA44FF", "#FF00FF", "#FF6B6B", "#FFD700"]
        t = time.time() * speed
        idx = int((t + position) % len(colors))
        return colors[idx]

def get_rainbow_color(offset=0, speed=1.0):
    return AnimatedBorder.get_instance().get_rainbow_color(offset, speed)

def get_border_style(position=0, speed=0.8):
    return AnimatedBorder.get_instance().get_moving_border_style(position, speed)

def hexa_alert(message: str, kind: str = "info") -> None:
    tags = {
        "success": ("✓", SUCCESS),
        "error": ("✗", ERR),
        "warning": ("⚠", WARN),
        "info": ("▶", ACCENT),
    }
    tag, color = tags.get(kind, tags["info"])
    console.print(f"  {tag}  {message}  [dim]| {CREDIT}[/dim]", style=color)

def hexa_section(title: str) -> None:
    console.print()
    console.print(f"  ═══ {title} ═══  [dim]({CREDIT})[/dim]", style=f"bold {ACCENT}")
    console.print(f"  {'─' * (len(title) + 8)}", style=MUTED)

def hexa_prompt(label: str) -> str:
    console.print(f"  {label}  [dim]· {CREDIT}[/dim]", style=f"bold {NEON}")
    return safe_input("  └─> ").strip()

def print_credit():
    """Print credit footer."""
    t = Text()
    t.append("  ✦ ", style=f"bold {GOLD}")
    t.append("by ", style="dim")
    t.append(CREDIT, style=f"bold {NEON}")
    t.append("  ·  ", style="dim")
    t.append("@L4DXOP", style=f"{GOLD}")
    t.append("  ✦", style=f"bold {GOLD}")
    console.print(t)

def format_time(seconds: int) -> str:
    if seconds < 0: return "Unlimited"
    if seconds == 0: return "Expired"
    days = seconds // 86400
    hours = (seconds % 86400) // 3600
    minutes = (seconds % 3600) // 60
    secs = seconds % 60
    if days > 0: return f"{days}d {hours}h {minutes}m {secs}s"
    elif hours > 0: return f"{hours}h {minutes}m {secs}s"
    else: return f"{minutes}m {secs}s"

def print_main_banner(title="", key_info=None):
    os.system('cls' if os.name == 'nt' else 'clear')
    try:
        term_width = shutil.get_terminal_size().columns
    except:
        term_width = 80
    BOX_WIDTH = 60
    padding = max(0, (term_width - BOX_WIDTH) // 2)
    pad = " " * padding
    ab = AnimatedBorder.get_instance()
    top_line = "╔" + "═" * (BOX_WIDTH - 2) + "╗"
    sep_line = "╠" + "═" * (BOX_WIDTH - 2) + "╣"
    sep2_line = "╟" + "─" * (BOX_WIDTH - 2) + "╢"
    bot_line = "╚" + "═" * (BOX_WIDTH - 2) + "╝"
    c1 = ab.get_moving_border_style(0, 0.6)
    c2 = ab.get_moving_border_style(4, 0.6)
    c3 = ab.get_moving_border_style(8, 0.6)
    def make_center_line(text):
        content_len = len(text)
        total_pad = BOX_WIDTH - 2 - content_len
        left_pad = total_pad // 2
        right_pad = total_pad - left_pad
        return "║" + " " * left_pad + text + " " * right_pad + "║"
    console.print(pad + f"[{c1}]{top_line}[/{c1}]")
    console.print(pad + make_center_line(TOOL_NAME), style=f"bold {GREEN}")
    console.print(pad + f"[{c2}]{sep_line}[/{c2}]")
    console.print(pad + make_center_line("REAL DEVELOPER @L4DXOP"), style=f"bold {GREEN}")
    console.print(pad + make_center_line(f"CREDIT  {CREDIT}"), style=f"bold {NEON}")
    console.print(pad + f"[{c3}]{sep2_line}[/{c3}]")
    console.print(pad + make_center_line("🔓 UNLIMITED VERSION"), style=f"bold {GOLD}")
    console.print(pad + make_center_line("⚡ FULL ACCESS - NO RESTRICTIONS"), style=f"bold {NEON}")
    console.print(pad + make_center_line("📱 DEVICES     : UNLIMITED"), style=NEON)
    console.print(pad + make_center_line("⏰ EXPIRY      : ♾️ LIFETIME"), style=f"bold {GREEN}")
    console.print(pad + make_center_line(f"💎 BY          : {CREDIT}"), style=f"bold {GOLD}")
    console.print(pad + f"[{c3}]{bot_line}[/{c3}]")
    console.print()
    if title:
        console.print(f"  {title}", style=f"bold {ACCENT}")
        console.print(f"  {'─' * len(title)}", style=MUTED)

def human_size(size: int) -> str:
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024.0:
            return f'{size:.2f} {unit}'
        size /= 1024.0
    return f'{size:.2f} PB'

# ==============================================================================
# SHARED DIRECTORY CONFIGURATION  |  CREDIT: @L4DXOP
# ==============================================================================

def get_lua_pak_root() -> Path:
    docs_path = Path("/storage/emulated/0/Documents/L4DXOP_LUA_TOOL")
    if not docs_path.exists():
        docs_path.mkdir(parents=True, exist_ok=True)
        console.print(f"[{SUCCESS}]✓ Created L4DXOP_LUA_TOOL folder at {docs_path}  [dim]({CREDIT})[/dim][/{SUCCESS}]")
    return docs_path

LUA_PAK_ROOT = get_lua_pak_root()
SOURCE_DIR = LUA_PAK_ROOT / "SOURCE"
REAL_DIR   = LUA_PAK_ROOT / "LUA_ORIGINAL"
EDIT_DIR   = LUA_PAK_ROOT / "COMPILED"
UNPACK_DIR = LUA_PAK_ROOT / "LUA_EDIT"
PAK_DIR    = LUA_PAK_ROOT / "PAK_ORIGINAL"
PAK_UNPACK_DIR = LUA_PAK_ROOT / "PAK_UNPACK"
RESULT_DIR = LUA_PAK_ROOT / "PAK_RESULT"
CONFIG_FILE_PATH = LUA_PAK_ROOT / "config.json"
DECOMP_LOG_FILE = LUA_PAK_ROOT / "decompile_debug.log"

def decomp_log(message: str):
    try:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        line = f"[{timestamp}] {message}"

        with open(DECOMP_LOG_FILE, "a", encoding="utf-8") as log:
            log.write(line + "\n")

        console.print(f"[dim]{line}[/dim]")
    except Exception as e:
        console.print(f"[yellow]DEBUG LOG ERROR: {e}[/yellow]")
            
FORCE_COMPILE = True
SKIP_ALL_FIXES = True
SKIP_AUTO_FIX = True

def load_config():
    config = {}
    if CONFIG_FILE_PATH.exists():
        try:
            with open(CONFIG_FILE_PATH, 'r') as f:
                config = json.load(f)
        except Exception:
            pass
    return config

def save_config(config):
    try:
        with open(CONFIG_FILE_PATH, 'w') as f:
            json.dump(config, f, indent=2)
    except Exception:
        pass

def hexa_prompt_with_default(label: str, default: str = "") -> str:
    console.print(f"  {label}  [dim]· {CREDIT}[/dim]", style=f"bold {NEON}")
    if default:
        console.print(f"  └─> [bold green]{default}[/bold green]", style=f"bold")
        console.print(f"  [dim](Press Enter to use default, or type new path)[/dim]")
        result = safe_input("  └─> ").strip()
        return result if result else default
    else:
        return safe_input("  └─> ").strip()

def setup_directories():
    for d in [REAL_DIR, UNPACK_DIR, EDIT_DIR, PAK_DIR, PAK_UNPACK_DIR, RESULT_DIR, SOURCE_DIR]:
        try: d.mkdir(parents=True, exist_ok=True)
        except OSError as e: console.print(f"Error creating {d}: {e}")

def get_real_files():
    return [f for f in os.listdir(REAL_DIR) if f.lower().endswith((".lua",".luac",".slua"))] if REAL_DIR.exists() else []

def get_unpack_files():
    return [f for f in os.listdir(UNPACK_DIR) if f.endswith(".lua")] if UNPACK_DIR.exists() else []

# ==============================================================================
# TOOLCHAIN — LUA CORE (FULL)  |  CREDIT: @L4DXOP
# ==============================================================================

def _load_xor_key() -> bytes:
    env_key = os.environ.get('BGMI_XOR_KEY')
    if env_key:
        try:
            key_bytes = bytes.fromhex(env_key.replace(' ', '').replace(':', '').replace('-', ''))
            if len(key_bytes) == 32: return key_bytes
        except ValueError: pass
    return bytes([0x11, 0x21, 0x36, 0x47, 0x46, 0x57, 0xA7, 0x8D, 0x9D, 0x84, 0x90, 0xD8, 0xAB, 0x00, 0x8C, 0x35, 0x26, 0x1A, 0xF7, 0xE4, 0x58, 0x05, 0xB8, 0xB3, 0x15, 0x07, 0xD0, 0x2C, 0x1E, 0x8F, 0xF6, 0xC8])

STRING_XOR_KEY = _load_xor_key()

_BGMI_TO_STD = [13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,0,1,2,3,4,5,6,7,8,9,10,11,12,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46]
BGMI_TO_STD = _BGMI_TO_STD + [i for i in range(len(_BGMI_TO_STD), 64)]
STD_TO_BGMI = {v: k for k, v in enumerate(BGMI_TO_STD) if k < len(BGMI_TO_STD)}
STD_FMT = [0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,2,2,0,2,0,1,0,3]
iABC, iABx, iAsBx, iAx = 0, 1, 2, 3
HEADER_SIZE = 33

class BinaryReader:
    def __init__(self, data: bytes, sizet: int = 4):
        self.data = bytearray(data); self.pos = 0; self.sizet = sizet
    def byte(self) -> int:
        if self.pos >= len(self.data): raise EOFError()
        v = self.data[self.pos]; self.pos += 1; return v
    def int32(self) -> int:
        if self.pos + 4 > len(self.data): raise EOFError()
        v = struct.unpack_from('<i', self.data, self.pos)[0]; self.pos += 4; return v
    def uint32(self) -> int:
        if self.pos + 4 > len(self.data): raise EOFError()
        v = struct.unpack_from('<I', self.data, self.pos)[0]; self.pos += 4; return v
    def double(self) -> float:
        if self.pos + 8 > len(self.data): raise EOFError()
        v = struct.unpack_from('<d', self.data, self.pos)[0]; self.pos += 8; return v
    def int64(self) -> int:
        if self.pos + 8 > len(self.data): raise EOFError()
        v = struct.unpack_from('<q', self.data, self.pos)[0]; self.pos += 8; return v
    def bytes(self, n: int) -> bytes:
        if self.pos + n > len(self.data): raise EOFError()
        v = self.data[self.pos:self.pos+n]; self.pos += n; return bytes(v)
    def pubg_string(self) -> Optional[str]:
        sz = self.byte()
        if sz == 0xFF: sz = self.uint32()
        if sz == 0: return None
        sz -= 1
        enc = self.bytes(sz)
        dec = bytes(enc[i] ^ STRING_XOR_KEY[i % 32] for i in range(len(enc)))
        try: return dec.decode('utf-8', errors='replace')
        except Exception: return dec.decode('latin-1')
    def std_string(self) -> Optional[str]:
        sz = self.byte()
        if sz == 0xFF:
            if self.sizet == 8:
                if self.pos + 8 > len(self.data): raise EOFError()
                sz = struct.unpack_from('<Q', self.data, self.pos)[0]; self.pos += 8
            else: sz = self.uint32()
        if sz == 0: return None
        sz -= 1
        raw = self.bytes(sz)
        try: return raw.decode('utf-8', errors='replace')
        except Exception: return raw.decode('latin-1')

class BinaryWriter:
    def __init__(self): self.buf = bytearray()
    def byte(self, v): self.buf.append(v & 0xFF)
    def int32(self, v): self.buf.extend(struct.pack('<i', v))
    def uint32(self, v): self.buf.extend(struct.pack('<I', v))
    def int64(self, v): self.buf.extend(struct.pack('<q', v))
    def double(self, v): self.buf.extend(struct.pack('<d', v))
    def raw(self, data): self.buf.extend(data)
    def lua_string(self, s: Optional[str], is_pubg: bool = False):
        if s is None: self.byte(0); return
        e = s.encode('utf-8') if isinstance(s, str) else s
        sz = len(e) + 1
        if sz < 0xFF: self.byte(sz)
        else: self.byte(0xFF); self.uint32(sz)
        if is_pubg:
            enc = bytes(e[i] ^ STRING_XOR_KEY[i % 32] for i in range(len(e)))
            self.raw(enc)
        else: self.raw(e)
    def lua_inst(self, op, A, B, C, Bx, sBx, Ax, fmt):
        op &= 0x3F
        if   fmt == iABC:  r = op | ((A & 0xFF)<<6) | ((C & 0x1FF)<<14) | ((B & 0x1FF)<<23)
        elif fmt == iABx:  r = op | ((A & 0xFF)<<6) | ((Bx & 0x3FFFF)<<14)
        elif fmt == iAsBx: r = op | ((A & 0xFF)<<6) | (((sBx+131071) & 0x3FFFF)<<14)
        elif fmt == iAx:   r = op | ((Ax & 0x3FFFFFF)<<6)
        else: r = 0
        self.uint32(r)
    def get_data(self) -> bytes: return bytes(self.buf)

def _convert_function(reader: BinaryReader, writer: BinaryWriter, to_std: bool = True):
    src = reader.pubg_string() if to_std else reader.std_string()
    writer.lua_string(src, is_pubg=(not to_std))
    linedefined = reader.int32(); writer.int32(linedefined)
    writer.int32(reader.int32())
    writer.byte(reader.byte()); writer.byte(reader.byte()); writer.byte(reader.byte())
    csz = reader.uint32(); writer.uint32(csz)
    opmap = BGMI_TO_STD if to_std else STD_TO_BGMI
    for _ in range(csz):
        raw = reader.uint32()
        bop = raw & 0x3F; A = (raw >> 6) & 0xFF; B = (raw >> 23) & 0x1FF; C = (raw >> 14) & 0x1FF
        Bx = (raw >> 14) & 0x3FFFF; sBx = Bx - 131071; Ax = (raw >> 6) & 0x3FFFFFF
        sop = opmap[bop] if bop < len(opmap) else bop
        fmt = STD_FMT[sop] if sop < len(STD_FMT) else iABC
        writer.lua_inst(sop, A, B, C, Bx, sBx, Ax, fmt)
    nk = reader.uint32(); writer.uint32(nk)
    for _ in range(nk):
        t = reader.byte(); writer.byte(t)
        if t == 0: pass
        elif t == 1: writer.byte(reader.byte())
        elif t == 3: writer.double(reader.double())
        elif t == 19: writer.int64(reader.int64())
        elif t in (4, 20):
            s = reader.pubg_string() if to_std else reader.std_string()
            writer.lua_string(s, is_pubg=(not to_std))
        else: raise ValueError(f"Unknown constant type 0x{t:02X}")
    nups = reader.uint32(); writer.uint32(nups)
    for _ in range(nups): writer.byte(reader.byte()); writer.byte(reader.byte())
    npts = reader.uint32(); writer.uint32(npts)
    for _ in range(npts): _convert_function(reader, writer, to_std)
    nln = reader.uint32()
    if to_std:
        lines = []; cur = linedefined
        for _ in range(nln):
            d = reader.byte()
            cur += d if d <= 127 else d - 256
            lines.append(cur)
        writer.uint32(len(lines))
        for ln in lines: writer.int32(ln)
        nab = reader.uint32()
        for _ in range(nab): reader.uint32(); reader.uint32()
    else:
        lines = [reader.int32() for _ in range(nln)]
        writer.uint32(len(lines))
        prev = linedefined
        for ln in lines:
            delta = ln - prev
            if -128 <= delta <= 127: writer.byte(delta & 0xFF)
            else: writer.byte(0x00); writer.int32(delta)
            prev = ln
        writer.uint32(0)
    nloc = reader.uint32(); writer.uint32(nloc)
    for _ in range(nloc):
        s = reader.pubg_string() if to_std else reader.std_string()
        writer.lua_string(s, is_pubg=(not to_std))
        writer.int32(reader.int32()); writer.int32(reader.int32())
    nupn = reader.uint32(); writer.uint32(nupn)
    for _ in range(nupn):
        s = reader.pubg_string() if to_std else reader.std_string()
        writer.lua_string(s, is_pubg=(not to_std))

def bgmi_to_std(data: bytes) -> bytes:
    if data[:4] != b'\x1bLua': raise ValueError("Not a valid Lua bytecode file")
    reader = BinaryReader(data, sizet=4); writer = BinaryWriter()
    hdr = bytearray(data[:HEADER_SIZE]); hdr[13] = 4
    writer.raw(hdr); reader.pos = HEADER_SIZE
    nibble_flag = reader.byte(); writer.byte(nibble_flag)
    _convert_function(reader, writer, to_std=True)
    return writer.get_data()

def std_to_bgmi(data: bytes) -> bytes:
    if data[:4] != b'\x1bLua': raise ValueError("Not a valid Lua bytecode file")
    sizet = data[13] if data[13] in (4, 8) else 4
    reader = BinaryReader(data, sizet=sizet); writer = BinaryWriter()
    hdr = bytearray(data[:HEADER_SIZE]); hdr[13] = 4
    writer.raw(hdr); reader.pos = HEADER_SIZE
    nibble_flag = reader.byte(); writer.byte(nibble_flag)
    _convert_function(reader, writer, to_std=False)
    return writer.get_data()

def convert_file(inp: str, outp: str = None) -> Tuple[bool, str]:
    if not outp: outp = os.path.splitext(inp)[0] + '.std.luac'
    try:
        with open(inp, 'rb') as f: data = f.read()
    except Exception as e: return False, f"Cannot read input file: {e}"
    if len(data) < 34 or data[:4] != b'\x1bLua':
        try: shutil.copy2(inp, outp); return True, outp
        except: return False, "Failed to copy non-Lua file"
    nibble_flag = data[33]
    if nibble_flag > 2: nibble_flag = 0; data = bytearray(data); data[33] = 0; data = bytes(data)
    if nibble_flag > 1:
        fixed = bytearray(data[:34])
        for i in range(34, len(data)):
            b = data[i]; fixed.append(((b << 4) & 0xF0) | ((b >> 4) & 0x0F))
        data = bytes(fixed)
    try:
        std_data = bgmi_to_std(data)
        with open(outp, 'wb') as f: f.write(std_data)
        return True, outp
    except Exception:
        try: shutil.copy2(inp, outp); return True, outp
        except: return False, "Conversion failed"

def repack_to_pubg(std_luac_path: str, original_pubg_path: str, outp: str = None, pad_to_size: int = None) -> Tuple[bool, str]:
    if not outp: outp = os.path.splitext(std_luac_path)[0] + '.pubg.luac'
    try:
        with open(original_pubg_path, 'rb') as f: orig_data = f.read()
    except Exception as e: return False, f"Cannot read original: {e}"
    if len(orig_data) < 34 or orig_data[:4] != b'\x1bLua': return False, "Original not valid Lua bytecode"
    header = orig_data[:33]; nibble_flag = orig_data[33]
    if nibble_flag > 2: nibble_flag = 0
    try:
        with open(std_luac_path, 'rb') as f: std_data = f.read()
    except Exception as e: return False, f"Cannot read std luac: {e}"
    try:
        bgmi_data = std_to_bgmi(std_data)
        bgmi_data = header + bytes([nibble_flag]) + bgmi_data[34:]
        if nibble_flag > 1:
            data_list = bytearray(bgmi_data[:34])
            for i in range(34, len(bgmi_data)):
                b = bgmi_data[i]; data_list.append(((b << 4) & 0xF0) | ((b >> 4) & 0x0F))
            bgmi_data = bytes(data_list)
        if pad_to_size is not None and len(bgmi_data) < pad_to_size:
            bgmi_data += b'\x00' * (pad_to_size - len(bgmi_data))
        with open(outp, 'wb') as f: f.write(bgmi_data)
        return True, outp
    except Exception as e: return False, f"Repack failed: {e}"

UNLUAC_JAR_PATH = SOURCE_DIR / "unluac_patched.jar"
UNLUAC_JAR = str(UNLUAC_JAR_PATH)
JAVA_CMD = "java"
BUNDLED_JDK_CANDIDATES = list(SOURCE_DIR.glob("jdk*/bin/java.exe")) + list(SOURCE_DIR.glob("jdk*/bin/java"))
if BUNDLED_JDK_CANDIDATES: JAVA_CMD = str(BUNDLED_JDK_CANDIDATES[0])

def get_luac_cmd() -> str:
    for name in ["luac5.3", "luac53", "luac5.3.exe", "luac53.exe"]:
        p = SOURCE_DIR / name
        if p.exists(): return str(p)
    for name in ["luac5.3", "luac53.exe"]:
        w = shutil.which(name)
        if w: return w
    return "luac5.3"

LUAC_PATH = get_luac_cmd()
STRIP_DEBUG = True

def decrypt_decompile_file(file_path: str, output_dir: str, progress_callback=None) -> bool:
    try:
        filename = os.path.basename(file_path)
        base_name = os.path.splitext(filename)[0]
        if base_name.lower().endswith('.lua'): base_name = os.path.splitext(base_name)[0]
        output_file = os.path.join(output_dir, base_name + ".lua")
        temp_std = file_path + ".temp.std.luac"
        if progress_callback: progress_callback(f"Converting {filename}...")
        success, msg = convert_file(file_path, temp_std)
        if not success:
            if progress_callback: progress_callback(f"Conversion failed: {msg}")
            shutil.copy2(file_path, os.path.join(output_dir, base_name + ".luac"))
            return False
        if not os.path.exists(UNLUAC_JAR):
            if progress_callback: progress_callback("unluac.jar missing, saving raw bytecode")
            shutil.copy2(temp_std, os.path.join(output_dir, base_name + ".luac"))
            os.remove(temp_std); return False
        try:
            cmd = [JAVA_CMD, "-jar", UNLUAC_JAR, temp_std]
            with open(output_file, "w", encoding="utf-8") as out:
                subprocess.check_call(cmd, stdout=out, stderr=subprocess.PIPE, timeout=30)
            if progress_callback: progress_callback(f"Decompiled {filename}")
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            if progress_callback: progress_callback(f"Decompilation failed: {e}")
            shutil.copy2(temp_std, os.path.join(output_dir, base_name + ".luac"))
            return False
        finally:
            if os.path.exists(temp_std): os.remove(temp_std)
        return True
    except Exception as e:
        if progress_callback: progress_callback(f"Exception: {e}")
        return False

    def robust_decompile(encrypted_path: str, output_dir: str, tmp_dir: str) -> Tuple[bool, str, List[str]]:
        name = os.path.basename(encrypted_path)
        base = os.path.splitext(name)[0]

        out_path = os.path.join(output_dir, base + ".lua")
        temp_std = os.path.join(tmp_dir, base + ".std.luac")

        decomp_log("=" * 80)
        decomp_log(f"START DECOMPILATION: {name}")
        decomp_log(f"Input: {encrypted_path}")
        decomp_log(f"Output: {out_path}")
        decomp_log(f"Temp dir: {tmp_dir}")
        decomp_log(f"Temp bytecode: {temp_std}")

        try:
            if os.path.exists(encrypted_path):
                decomp_log(
                    f"Input size: {os.path.getsize(encrypted_path):,} bytes"
                )
            else:
                decomp_log("ERROR: input file does not exist")
                return False, "Input file not found", []

            decomp_log("STEP 1: convert_file()")

            ok, msg = convert_file(encrypted_path, temp_std)

            decomp_log(f"convert_file result: ok={ok}")
            decomp_log(f"convert_file message: {msg}")

            if not ok:
                decomp_log("STOP: conversion failed")
                return False, msg, []

            if not os.path.exists(temp_std):
                decomp_log("STOP: converted bytecode file was not created")
                return False, "Converted bytecode file not created", []

            decomp_log(
                f"Converted bytecode size: {os.path.getsize(temp_std):,} bytes"
            )

            decomp_log(f"UNLUAC_JAR: {UNLUAC_JAR}")
            decomp_log(f"JAVA_CMD: {JAVA_CMD}")

            if not os.path.exists(UNLUAC_JAR):
                decomp_log("STOP: unluac_patched.jar not found")
                return False, "unluac_patched.jar not found", []

            decomp_log(
                f"JAR size: {os.path.getsize(UNLUAC_JAR):,} bytes"
            )

            cmd = [JAVA_CMD, "-jar", UNLUAC_JAR, temp_std]

            decomp_log(f"COMMAND: {cmd}")

            start_time = time.time()

            decomp_log("STEP 2: launching unluac")

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )

            elapsed = time.time() - start_time

            decomp_log(
                f"unluac finished in {elapsed:.3f} seconds"
            )

            decomp_log(
                f"RETURN CODE: {result.returncode}"
            )

            decomp_log(
                f"STDOUT LENGTH: {len(result.stdout or '')}"
            )

            decomp_log(
                f"STDERR LENGTH: {len(result.stderr or '')}"
            )

            if result.stdout:
                decomp_log("----- UNLUAC STDOUT BEGIN -----")
                decomp_log(result.stdout.rstrip())
                decomp_log("----- UNLUAC STDOUT END -----")

            if result.stderr:
                decomp_log("----- UNLUAC STDERR BEGIN -----")
                decomp_log(result.stderr.rstrip())
                decomp_log("----- UNLUAC STDERR END -----")

            if result.returncode == 0 and result.stdout:
                try:
                    with open(out_path, "w", encoding="utf-8") as f:
                        f.write(result.stdout)

                    output_size = os.path.getsize(out_path)

                    decomp_log(
                        f"SUCCESS: output created: {out_path}"
                    )

                    decomp_log(
                        f"Output size: {output_size:,} bytes"
                    )

                    decomp_log("DECOMPILATION SUCCESS")

                    return True, out_path, []

                except Exception as write_error:
                    decomp_log(
                        f"ERROR writing output: {write_error}"
                    )

                    decomp_log(traceback.format_exc())

                    return False, str(write_error), []

            error_text = (
                result.stderr.strip()
                if result.stderr
                else result.stdout.strip()
                if result.stdout
                else "unknown error"
            )

            decomp_log(
                f"DECOMPILATION FAILED: {error_text}"
            )

            return False, (
                f"Decompilation failed: {error_text[:500]}"
            ), []

        except subprocess.TimeoutExpired as e:
            decomp_log("ERROR: unluac TIMEOUT after 30 seconds")
            decomp_log(f"Timeout exception: {e}")
            decomp_log(traceback.format_exc())

            return False, "Decompilation timed out", []

        except Exception as e:
            decomp_log(f"EXCEPTION: {e}")
            decomp_log(traceback.format_exc())

            return False, str(e), []

        finally:
            if os.path.exists(temp_std):
                try:
                    decomp_log(
                        f"Removing temporary file: {temp_std}"
                    )
                    os.remove(temp_std)
                except Exception as cleanup_error:
                    decomp_log(
                        f"Failed to remove temp file: {cleanup_error}"
                    )

            decomp_log(f"END DECOMPILATION: {name}")
            decomp_log("=" * 80)

def select_files_interactive(files: List[str], source_dir: str, action_name: str) -> List[str]:
    if not files: return []
    if len(files) == 1:
        console.print(f"Only 1 file found: {files[0]}  [dim]· {CREDIT}[/dim]")
        confirm = hexa_prompt("Process this file? (Y/n): ").strip().lower()
        return files if confirm != 'n' else []
    console.print(f"\nSelect files to {action_name}  [dim]· {CREDIT}[/dim]")
    for idx, f in enumerate(files, 1):
        sz = os.path.getsize(os.path.join(source_dir, f))
        console.print(f"  [{idx}] {f} ({sz:,} bytes)")
    console.print("  [A] ALL FILES")
    console.print("  [0] Cancel")
    while True:
        choice = hexa_prompt("Your choice: ").strip().upper()
        if choice == 'A': return files
        if choice == '0': return []
        if choice.isdigit():
            idx = int(choice)
            if 1 <= idx <= len(files): return [files[idx-1]]
        console.print("Invalid selection!")

def action_unpack():
    files = get_real_files()
    if not files: hexa_alert("LUA_ORIGINAL folder is empty!", "error"); safe_input('\nPress Enter...'); return
    selected = select_files_interactive(files, str(REAL_DIR), "UNPACK")
    if not selected: return
    success = 0
    with tempfile.TemporaryDirectory(prefix='bgmi_dec_') as tmp_dir:
        for idx, f in enumerate(selected, 1):
            console.print(f"[{idx}/{len(selected)}] {f}  [dim]· {CREDIT}[/dim]")
            inp = REAL_DIR / f
            ok, result, _ = robust_decompile(str(inp), str(UNPACK_DIR), tmp_dir)
            if ok:
                console.print(f"Decompiled: {os.path.basename(result)}"); success += 1
            else:
                console.print(f"Failed: {result}")
                fallback_path = UNPACK_DIR / (os.path.splitext(f)[0] + ".luac")
                ok2, _ = convert_file(str(inp), str(fallback_path))
                if ok2: console.print(f"Saved raw bytecode as {fallback_path}")
    hexa_alert(f"Unpack Complete! {success}/{len(selected)} files decompiled.  [dim]· {CREDIT}[/dim]", "success")
    safe_input('\nPress Enter...')

def recompile_lua_files(selected: List[str], quiet: bool = False) -> Tuple[int, List[str]]:
    success = 0; failed = []
    for idx, f in enumerate(selected, 1):
        name = os.path.splitext(f)[0]
        inp = UNPACK_DIR / f
        out = EDIT_DIR / (name + ".lua")
        console.print(f"[{idx}/{len(selected)}] {f}  [dim]· {CREDIT}[/dim]")

        if FORCE_COMPILE:
            console.print(f"[bold yellow]FORCE COMPILE L4DXOP POWER FULL TOOL  [dim]· {CREDIT}[/dim][/bold yellow]")

        temp_std = str(LUA_PAK_ROOT / f"{name}_temp_std.luac")
        cmd = [LUAC_PATH, "-s", "-o", temp_std, str(inp)] if STRIP_DEBUG else [LUAC_PATH, "-o", temp_std, str(inp)]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        except subprocess.TimeoutExpired:
            console.print("Compilation timed out")
            failed.append(f)
            continue

        if res.returncode == 0 and os.path.exists(temp_std):
            orig = None
            for ext in ['.luac', '.slua', '.lua']:
                p = REAL_DIR / (name + ext)
                if p.exists():
                    orig = str(p)
                    break
            if not orig:
                console.print("Original file not found in LUA_ORIGINAL")
                failed.append(f)
            else:
                ok2, msg = repack_to_pubg(temp_std, orig, str(out), pad_to_size=os.path.getsize(orig))
                if ok2:
                    console.print(f"Recompiled: {out.name} ({out.stat().st_size:,} bytes)  [dim]· {CREDIT}[/dim]")
                    success += 1
                else:
                    console.print(f"Recompile failed: {msg}")
                    failed.append(f)
            if os.path.exists(temp_std):
                os.remove(temp_std)
        else:
            console.print(f"Compilation failed: {res.stderr.strip() if res.stderr else 'Unknown error'}")
            failed.append(f)
    return success, failed

def action_repack_unpack():
    files = get_unpack_files()
    if not files: hexa_alert("LUA_EDIT folder is empty!", "error"); safe_input('\nPress Enter...'); return
    selected = select_files_interactive(files, str(UNPACK_DIR), "REPACK")
    if not selected: return

    if FORCE_COMPILE and SKIP_ALL_FIXES:
        console.print(f"[bold cyan] 🚀 FAST COMPILE MODE — Raw Build Execution  [dim]· {CREDIT}[/dim][/bold cyan]")
        console.print(f"[bold cyan]Launching high-speed compilation...  [dim]· {CREDIT}[/dim][/bold cyan]")

    success, failed = recompile_lua_files(selected)
    hexa_alert(f"Repack Complete! {success}/{len(selected)} successful.  [dim]· {CREDIT}[/dim]", "success")
    if failed: hexa_alert(f"Failed files: {', '.join(failed)}", "error")
    safe_input('\nPress Enter...')

# ==============================================================================
# TOOLCHAIN — PAK CORE (COMPLETE)  |  CREDIT: @L4DXOP
# ==============================================================================

ZUC_KEY = bytes.fromhex('01010101010101010101010101010101')
ZUC_IV = bytes.fromhex('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')

RSA_MOD_1 = bytes.fromhex('CBE8B9F2504050EF9831B719E9A6249A6D238505ADE909BDE78C180DED6072A0C3347B8AF4780E1F212D952D82D4BF7F233C1ECA499E1F9D9A85B4FAD759F54BABC1666C5DE411EA9E4B2374425DD6C6F54333BBC8F2610FE6063E4D0D6C21A671A8F7C3740555E5DC06D4E1691C456DB4116C0C012BF7B206E8311AAAEC689952BF804EF638F09D5822B4117B114208F14DEB459E80CB770E5B0D7978E21F5E6CED4999D3583108221A7AB28B960277ADB5690A332784019D9C195BE4EA9EA0A09459010F236465DE0D59C3EF7324E954E1118D93EE19F299760C2CDB963CE87973EA5ECC9BBE81C27D4C7C8572AC07E9BCEAC9BD72AB7A56A3C0AD736ABCE4')
RSA_MOD_2 = bytes.fromhex('7F58E8A39A4DA4E87357DDD650EAA16D3B5CE95B213D1030A662566444796A78A84AE9AC3DBFFDE7F41094896696835DAF13B89E6EC2B84963B1B1BAF7151DA245C3FBFAE2A6AE18B2684D03F9229DE2C91440F2A3A3BCDE1E5680C16722A88039C73560D5D43F4B6562C2EEA5B1D926D86B51108A2643C70FB74D6442CE3A08339B8FD8F660AE88129B7AB8C46F2FA58124485CCCB1E987B05A6DA65A01858ED3F89905449AE42BB07290FCB9994BF22E26610BCABB9804783A3B9587917F3D97316EDDA15C5E13F79066407B55A93B291B68A4AC42A98D6E35FED84B14A792D154E62028DDAD20FC301951E5924BE9AD62FB719DD94CC30CAB871BEC4377A8')

SIMPLE1_DECRYPT_KEY = 121
SIMPLE2_DECRYPT_KEY = bytes.fromhex('E55B4ED1')
SIMPLE2_BLOCK_SIZE = 16

SM4_SECRET_4 = 'eb691efea914241317a8'
SM4_SECRET_2 = 'Q0hVTKey$as*1ZFlQCiA'
SM4_SECRET_NEW = [
    "xG2qW5lP7lV2iN5fN5pG", "xT1cJ6dL5wC0kK1rB4dK", "qC4jS5bZ6fL5xE6nD4zA",
    "gD4jQ2aL3bS3lC3xT0iW", "xU1yQ8wE9zY3gZ3bT5aE", "uQ3cO2dX7xY4xU7gH7iS",
    "gW1fR0jK6wQ4oN0oK1kZ", "aJ4pV7iZ7pU4wP2aC2cZ", "cX6jT3cM2oT3vK0kJ1qN",
    "iT2vS0cS6yT6cZ1sE1lO", "hM1pH9iY8wM9hT4lN5uJ", "kG6bC8jK0fL0dE4sH4mL",
    "dB6lB3vE0eZ8wM8rI0aC", "tP7sP7nI9rA2vQ4cV5yQ", "aT0cL1yN4pT3sZ7eM2vY",
    "uV6fU8fC9zN3mP5dH8mN", "rT6aQ6oZ1yM0gO5tO1aN", "jU5bH7lQ0fM9hK2kI0o",
    "iQ0eM0mJ7uT0kV6kL5pY"
]

EM_SIMPLE1 = 1
EM_SIMPLE2 = 16
EM_SM4_2 = 2
EM_SM4_4 = 4
EM_SM4_NEW_BASE = 31
EM_SM4_NEW_MASK = ~EM_SM4_NEW_BASE

CM_NONE = 0
CM_ZLIB = 1
CM_ZSTD = 6
CM_ZSTD_DICT = 8
CM_MASK = 15

class SM4:
    _S_BOX = bytes([
        52, 102, 37, 116, 137, 120, 228, 169, 90, 65, 188, 122, 214, 22, 33, 35,
        77, 97, 218, 148, 155, 223, 19, 60, 105, 58, 49, 10, 95, 215, 153, 149,
        241, 174, 114, 61, 7, 96, 36, 182, 152, 238, 196, 162, 45, 136, 221, 141,
        4, 234, 187, 17, 202, 62, 93, 161, 246, 63, 176, 151, 128, 71, 43, 166,
        230, 247, 217, 177, 89, 192, 124, 190, 84, 40, 183, 126, 79, 248, 67, 110,
        160, 80, 14, 245, 144, 184, 251, 163, 123, 98, 25, 70, 3, 42, 185, 143,
        159, 119, 180, 91, 131, 135, 8, 235, 226, 30, 66, 240, 15, 232, 113, 106,
        117, 173, 85, 31, 181, 171, 51, 250, 127, 21, 189, 133, 216, 6, 104, 179,
        82, 48, 72, 11, 0, 237, 239, 178, 87, 142, 231, 108, 213, 229, 46, 83,
        130, 5, 249, 129, 244, 86, 191, 140, 75, 227, 219, 74, 145, 76, 44, 211,
        64, 41, 78, 32, 20, 54, 121, 9, 111, 209, 55, 224, 57, 12, 138, 146,
        56, 18, 53, 109, 225, 253, 147, 154, 23, 212, 201, 156, 107, 132, 38, 157,
        175, 118, 193, 158, 208, 150, 197, 203, 233, 115, 73, 210, 205, 100, 195, 199,
        1, 125, 243, 172, 252, 222, 164, 68, 50, 27, 194, 186, 28, 2, 198, 39,
        69, 139, 242, 24, 167, 16, 81, 29, 200, 207, 99, 255, 47, 13, 88, 206,
        101, 165, 220, 26, 59, 134, 254, 34, 92, 168, 94, 103, 170, 236, 112, 204
    ])
    _FK = [1184304796, 1270900830, 1493524870, 3164752158]
    _CK = [964907, 973793155, 2654690407, 2916866751, 2071233739, 1226140771, 3348805095, 2045549823, 388349611, 800627875, 612403927, 3721562911, 1195432523, 3150178931, 612053223, 2445162591, 67183755, 1174197155, 1393249511, 3331183455, 3822152747, 1332317203, 1804781383, 1990130463, 1282653851, 3376591251, 2910902311, 925872959, 332098219, 735840931, 396665415, 3588844719]

    @staticmethod
    def ROL32(x, n):
        return (x << n) & 0xFFFFFFFF | (x >> (32 - n))

    @staticmethod
    def _BS(X):
        return (SM4._S_BOX[X >> 24 & 255] << 24 |
                SM4._S_BOX[X >> 16 & 255] << 16 |
                SM4._S_BOX[X >> 8 & 255] << 8 |
                SM4._S_BOX[X & 255])

    @staticmethod
    def _T0(X):
        X = SM4._BS(X)
        return X ^ SM4.ROL32(X, 2) ^ SM4.ROL32(X, 10) ^ SM4.ROL32(X, 18) ^ SM4.ROL32(X, 24)

    @staticmethod
    def _T1(X):
        X = SM4._BS(X)
        return X ^ SM4.ROL32(X, 13) ^ SM4.ROL32(X, 23)

    @staticmethod
    def _key_expand(key: bytes, rkey: list):
        K0 = int.from_bytes(key[0:4], 'big') ^ SM4._FK[0]
        K1 = int.from_bytes(key[4:8], 'big') ^ SM4._FK[1]
        K2 = int.from_bytes(key[8:12], 'big') ^ SM4._FK[2]
        K3 = int.from_bytes(key[12:16], 'big') ^ SM4._FK[3]
        for i in range(0, 32, 4):
            K0 = K0 ^ SM4._T1(K1 ^ K2 ^ K3 ^ SM4._CK[i])
            rkey[i] = K0
            K1 = K1 ^ SM4._T1(K2 ^ K3 ^ K0 ^ SM4._CK[i + 1])
            rkey[i + 1] = K1
            K2 = K2 ^ SM4._T1(K3 ^ K0 ^ K1 ^ SM4._CK[i + 2])
            rkey[i + 2] = K2
            K3 = K3 ^ SM4._T1(K0 ^ K1 ^ K2 ^ SM4._CK[i + 3])
            rkey[i + 3] = K3

    @classmethod
    def key_length(cls):
        return 16

    @classmethod
    def block_length(cls):
        return 16

    def __init__(self, key: bytes):
        if len(key) != self.key_length():
            raise ValueError(f'Key must be {self.key_length()} bytes')
        else:
            self._key = key
            self._rkey = [0] * 32
            SM4._key_expand(self._key, self._rkey)
            self._block_buffer = bytearray()

    def encrypt(self, block: bytes) -> bytes:
        if len(block) != self.block_length():
            raise ValueError(f'Block must be {self.block_length()} bytes')
        else:
            RK = self._rkey
            X0 = int.from_bytes(block[0:4], 'big')
            X1 = int.from_bytes(block[4:8], 'big')
            X2 = int.from_bytes(block[8:12], 'big')
            X3 = int.from_bytes(block[12:16], 'big')
            for i in range(0, 32, 4):
                X0 = X0 ^ SM4._T0(X1 ^ X2 ^ X3 ^ RK[i])
                X1 = X1 ^ SM4._T0(X2 ^ X3 ^ X0 ^ RK[i + 1])
                X2 = X2 ^ SM4._T0(X3 ^ X0 ^ X1 ^ RK[i + 2])
                X3 = X3 ^ SM4._T0(X0 ^ X1 ^ X2 ^ RK[i + 3])
            BUFFER = self._block_buffer
            BUFFER.clear()
            BUFFER.extend(X3.to_bytes(4, 'big'))
            BUFFER.extend(X2.to_bytes(4, 'big'))
            BUFFER.extend(X1.to_bytes(4, 'big'))
            BUFFER.extend(X0.to_bytes(4, 'big'))
            return bytes(BUFFER)

    def decrypt(self, block: bytes) -> bytes:
        if len(block) != self.block_length():
            raise ValueError(f'Block must be {self.block_length()} bytes')
        else:
            RK = self._rkey
            X0 = int.from_bytes(block[0:4], 'big')
            X1 = int.from_bytes(block[4:8], 'big')
            X2 = int.from_bytes(block[8:12], 'big')
            X3 = int.from_bytes(block[12:16], 'big')
            for i in range(0, 32, 4):
                X0 = X0 ^ SM4._T0(X1 ^ X2 ^ X3 ^ RK[31 - i])
                X1 = X1 ^ SM4._T0(X2 ^ X3 ^ X0 ^ RK[30 - i])
                X2 = X2 ^ SM4._T0(X3 ^ X0 ^ X1 ^ RK[29 - i])
                X3 = X3 ^ SM4._T0(X0 ^ X1 ^ X2 ^ RK[28 - i])
            BUFFER = self._block_buffer
            BUFFER.clear()
            BUFFER.extend(X3.to_bytes(4, 'big'))
            BUFFER.extend(X2.to_bytes(4, 'big'))
            BUFFER.extend(X1.to_bytes(4, 'big'))
            BUFFER.extend(X0.to_bytes(4, 'big'))
            return bytes(BUFFER)

class Misc:
    @staticmethod
    def pad_to_n(data: bytes, n: int) -> bytes:
        assert n > 0
        padding = n - len(data) % n
        if padding == n:
            return data
        else:
            return data + b'\x00' * padding

    @staticmethod
    def align_up(x: int, n: int) -> int:
        return (x + n - 1) // n * n

class Reader:
    def __init__(self, buffer, cursor=0):
        self._buffer = buffer
        self._cursor = cursor
    def u1(self, move_cursor=True) -> int:
        return self.unpack('B', move_cursor=move_cursor)[0]
    def u4(self, move_cursor=True) -> int:
        return self.unpack('<I', move_cursor=move_cursor)[0]
    def u8(self, move_cursor=True) -> int:
        return self.unpack('<Q', move_cursor=move_cursor)[0]
    def i1(self, move_cursor=True) -> int:
        return self.unpack('b', move_cursor=move_cursor)[0]
    def i4(self, move_cursor=True) -> int:
        return self.unpack('<i', move_cursor=move_cursor)[0]
    def i8(self, move_cursor=True) -> int:
        return self.unpack('<q', move_cursor=move_cursor)[0]
    def s(self, n: int, move_cursor=True) -> bytes:
        return self.unpack(f'{n}s', move_cursor=move_cursor)[0]
    def unpack(self, f: str, offset=0, move_cursor=True):
        x = struct.unpack_from(f, self._buffer, self._cursor + offset)
        if move_cursor:
            self._cursor += struct.calcsize(f)
        return x
    def string(self, move_cursor=True) -> str:
        length = self.i4(move_cursor=move_cursor)
        if length == 0:
            return str()
        else:
            assert length > 0
            offset = 0 if move_cursor else 4
            raw = self.unpack(f'{length}s', offset=offset, move_cursor=move_cursor)[0].rstrip(b'\x00')
            return raw.replace(b'\x00', b'').decode('utf-8', errors='replace')

class PakInfo:
    def __init__(self, buffer, keystream: List[int]):
        def decrypt_index_encrypted(x: int) -> int:
            MASK_8 = 255
            return (x ^ keystream[3]) & MASK_8
        def decrypt_magic(x: int) -> int:
            return x ^ keystream[2]
        def decrypt_index_hash(x: bytes) -> bytes:
            key = struct.pack('<5I', *keystream[4:][:5])
            assert len(x) == len(key)
            return bytes((a ^ b for a, b in zip(x, key)))
        def decrypt_index_size(x: int) -> int:
            return x ^ (keystream[10] << 32 | keystream[11])
        def decrypt_index_offset(x: int) -> int:
            return x ^ (keystream[0] << 32 | keystream[1])
        reader = Reader(buffer[-PakInfo._mem_size((-1)):])
        self.index_encrypted = decrypt_index_encrypted(reader.u1()) == 1
        self.magic = decrypt_magic(reader.u4())
        self.version = reader.u4()
        self.index_hash = decrypt_index_hash(reader.s(20)) if self.version >= 6 else bytes()
        self.index_size = decrypt_index_size(reader.u8())
        self.index_offset = decrypt_index_offset(reader.u8())
        if self.version <= 3:
            self.index_encrypted = False
    @staticmethod
    def _mem_size(_: int) -> int:
        return 45

class TencentPakInfo(PakInfo):
    def __init__(self, buffer, keystream: List[int]):
        def decrypt_unk(x: bytes) -> bytes:
            key = struct.pack('<8I', *keystream[7:][:8])
            assert len(x) == len(key)
            return bytes((a ^ b for a, b in zip(x, key)))
        def decrypt_stem_hash(x: int) -> int:
            return x ^ keystream[8]
        def decrypt_unk_hash(x: int) -> int:
            return x ^ keystream[9]
        super().__init__(buffer, keystream)
        reader = Reader(buffer[-TencentPakInfo._mem_size(self.version):])
        self.unk1 = decrypt_unk(reader.s(32)) if self.version >= 7 else bytes()
        self.packed_key = reader.s(256) if self.version >= 8 else bytes()
        self.packed_iv = reader.s(256) if self.version >= 8 else bytes()
        self.packed_index_hash = reader.s(256) if self.version >= 8 else bytes()
        self.stem_hash = decrypt_stem_hash(reader.u4()) if self.version >= 9 else 0
        self.unk2 = decrypt_unk_hash(reader.u4()) if self.version >= 9 else 0
        self.content_org_hash = reader.s(20) if self.version >= 12 else bytes()
    @staticmethod
    def _mem_size(version: int) -> int:
        size_for_7 = 32 if version >= 7 else 0
        size_for_8 = 768 if version >= 8 else 0
        size_for_9 = 8 if version >= 9 else 0
        size_for_12 = 20 if version >= 12 else 0
        return PakInfo._mem_size(version) + size_for_7 + size_for_8 + size_for_9 + size_for_12

class PakCompressedBlock:
    def __init__(self, reader: Reader):
        self.start = reader.u8()
        self.end = reader.u8()

@dataclass
class TencentPakEntry:
    def __init__(self, reader: Reader, version: int):
        self.content_hash = reader.s(20)
        if version <= 1:
            _ = reader.u8()
        self.offset = reader.u8()
        self.uncompressed_size = reader.u8()
        self.compression_method = reader.u4() & CM_MASK
        self.size = reader.u8()
        self.unk1 = reader.u1() if version >= 5 else 0
        self.unk2 = reader.s(20) if version >= 5 else bytes()
        if self.compression_method != 0 and version >= 3:
            self.compressed_blocks = [PakCompressedBlock(reader) for _ in range(reader.u4())]
        else:
            self.compressed_blocks = []
        self.compression_block_size = reader.u4() if version >= 4 else 0
        self.encrypted = reader.u1() == 1 if version >= 4 else False
        self.encryption_method = reader.u4() if version >= 12 else 0
        self.index_new_sep = reader.u4() if version >= 12 else 0

class PakCrypto:
    class _LCG:
        def __init__(self, seed: int):
            self.state = seed
        def next(self) -> int:
            MASK_32 = 4294967295
            MSB_1 = 2147483648
            def wrap(x: int) -> int:
                x &= MASK_32
                if not x & MSB_1:
                    return x
                else:
                    return (x + MSB_1 & MASK_32) - MSB_1
            x1 = wrap(1103515245 * self.state)
            self.state = wrap(x1 + 12345)
            x2 = wrap(x1 + 77880) if self.state < 0 else self.state
            return (x2 >> 16 & MASK_32) % 32767
    @staticmethod
    def zuc_keystream() -> List[int]:
        try:
            zuc = gmalg.ZUC(ZUC_KEY, ZUC_IV)
            return [struct.unpack('>I', zuc.generate())[0] for _ in range(16)]
        except:
            return [0x9E3779B9, 0x3C6EF372, 0xDA7A5E2B, 0x7895C8E4, 0x16B1339D, 0xB4CC9E56, 0x52E8090F, 0xF10373C8, 0x8F1EDE81, 0x2D3A493A, 0xCB55B3F3, 0x69711EAC, 0x078C8965, 0xA5A7F41E, 0x43C35ED7, 0xE1DEC990]
    @staticmethod
    def _xorxor(buffer, x) -> bytes:
        return bytes((buffer[i] ^ x[i % len(x)] for i in range(len(buffer))))
    @staticmethod
    def _hashhash(buffer, n: int) -> bytes:
        result = bytes()
        for _ in range(math.ceil(n / SHA1.digest_size)):
            result += SHA1.new(buffer).digest()
        if len(result) >= n:
            result = result[:n]
            return result
        else:
            result += b'\x00' * (n - len(result))
            return result
    @staticmethod
    def _meowmeow(buffer) -> bytes:
        def unpad(x):
            skip = 1 + next((i for i in range(len(x)) if x[i]!= 0))
            return x[skip:]
        if len(buffer) < 43:
            return bytes()
        else:
            x1 = buffer[1:][:SHA1.digest_size]
            x2 = buffer[SHA1.digest_size + 1:]
            x1 = PakCrypto._xorxor(x1, PakCrypto._hashhash(x2, len(x1)))
            x2 = PakCrypto._xorxor(x2, PakCrypto._hashhash(x1, len(x2)))
            part1, m = (x2[:SHA1.digest_size], x2[SHA1.digest_size:])
            if part1!= SHA1.new(b'\x00' * SHA1.digest_size).digest():
                return bytes()
            else:
                return unpad(m)
    @staticmethod
    def rsa_extract(signature: bytes, modulus: bytes) -> bytes:
        c = int.from_bytes(signature, 'little')
        n = int.from_bytes(modulus, 'little')
        e = 65537
        m = pow(c, e, n).to_bytes(256, 'little').rstrip(b'\x00')
        return PakCrypto._meowmeow(Misc.pad_to_n(m, 4))
    @staticmethod
    def _decrypt_simple1(ciphertext) -> bytes:
        return bytes((x ^ SIMPLE1_DECRYPT_KEY for x in ciphertext))
    @staticmethod
    def _decrypt_simple2(ciphertext) -> bytes:
        class RollingKey:
            def __init__(self, initial_value: int):
                self._value = initial_value
            def update(self, x: int) -> int:
                self._value ^= x
                return self._value
        assert len(ciphertext) % SIMPLE2_BLOCK_SIZE == 0
        initial_key, = struct.unpack('<I', SIMPLE2_DECRYPT_KEY)
        rolling_key = RollingKey(initial_key)
        plaintext = (struct.pack('<I', rolling_key.update(x)) for x in struct.unpack(f'<{len(ciphertext) // 4}I', ciphertext))
        return bytes(it.chain.from_iterable(plaintext))
    @staticmethod
    @lru_cache(maxsize=1)
    def _derive_sm4_key(file_path: PurePath, encryption_method: int) -> bytes:
        part1 = file_path.stem.lower()
        if encryption_method == EM_SM4_2:
            secret = SM4_SECRET_2
        else:
            if encryption_method == EM_SM4_4:
                secret = SM4_SECRET_4
            else:
                index = (encryption_method - EM_SM4_NEW_BASE) % len(SM4_SECRET_NEW)
                secret = f'{SM4_SECRET_NEW[index]}{encryption_method}'
        return SHA1.new(str(part1 + secret).encode()).digest()[:SM4.key_length()]
    @staticmethod
    @lru_cache(maxsize=1)
    def _sm4_context_for_key(key: bytes) -> SM4:
        return SM4(key)
    @staticmethod
    def _decrypt_sm4(ciphertext, file_path: PurePath, encryption_method: int) -> bytes:
        assert len(ciphertext) % SM4.block_length() == 0
        key = PakCrypto._derive_sm4_key(file_path, encryption_method)
        sm4 = PakCrypto._sm4_context_for_key(key)
        return bytes(it.chain.from_iterable((sm4.decrypt(x) for x in it.batched(ciphertext, SM4.block_length()))))
    @staticmethod
    def decrypt_index(ciphertext, pak_info: TencentPakInfo) -> bytes:
        if pak_info.version > 7:
            try:
                key = PakCrypto.rsa_extract(pak_info.packed_key, RSA_MOD_1)
                iv = PakCrypto.rsa_extract(pak_info.packed_iv, RSA_MOD_1)
                if key and iv and len(key) == 32 and len(iv) >= 16:
                    aes = AES.new(key, MODE_CBC, iv[:16])
                    decrypted = aes.decrypt(ciphertext)
                    try:
                        return unpad(decrypted, AES.block_size)
                    except ValueError:
                        return decrypted
            except Exception:
                pass
            ks_bytes = struct.pack('<5I', *PakCrypto.zuc_keystream()[4:][:5])
            if len(ciphertext) < len(ks_bytes):
                ks_bytes = ks_bytes[:len(ciphertext)]
            else:
                ks_bytes = (ks_bytes * (len(ciphertext) // len(ks_bytes) + 1))[:len(ciphertext)]
            return bytes(a ^ b for a, b in zip(ciphertext, ks_bytes))
        else:
            return bytes(PakCrypto._decrypt_simple1(ciphertext))
    @staticmethod
    def _is_simple1_method(encryption_method: int) -> bool:
        return encryption_method == EM_SIMPLE1
    @staticmethod
    def _is_simple2_method(encryption_method: int) -> bool:
        return encryption_method == EM_SIMPLE2 or encryption_method == 17
    @staticmethod
    def _is_sm4_method(encryption_method: int) -> bool:
        return encryption_method == EM_SM4_2 or encryption_method == EM_SM4_4 or encryption_method & EM_SM4_NEW_MASK!= 0
    @staticmethod
    def align_encrypted_content_size(n: int, encryption_method: int) -> int:
        if PakCrypto._is_simple2_method(encryption_method):
            return Misc.align_up(n, SIMPLE2_BLOCK_SIZE)
        else:
            if PakCrypto._is_sm4_method(encryption_method):
                return Misc.align_up(n, SM4.block_length())
            else:
                return n
    @staticmethod
    def decrypt_block(ciphertext, file: PurePath, encryption_method: int) -> bytes:
        if PakCrypto._is_simple1_method(encryption_method):
            return PakCrypto._decrypt_simple1(ciphertext)
        else:
            if PakCrypto._is_simple2_method(encryption_method):
                return PakCrypto._decrypt_simple2(ciphertext)
            else:
                if PakCrypto._is_sm4_method(encryption_method):
                    return PakCrypto._decrypt_sm4(ciphertext, file, encryption_method)
                else:
                    return ciphertext
    @staticmethod
    @lru_cache(maxsize=33)
    def generate_block_indices(n: int, encryption_method: int) -> List[int]:
        if not PakCrypto._is_sm4_method(encryption_method):
            return list(range(n))
        else:
            permutation = []
            lcg = PakCrypto._LCG(n)
            while len(permutation)!= n:
                x = lcg.next() % n
                if x not in permutation:
                    permutation.append(x)
            inverse = [0] * len(permutation)
            for i, x in enumerate(permutation):
                inverse[x] = i
            return inverse

class PakCompression:
    @staticmethod
    @lru_cache(maxsize=33)
    def _zstd_decompressor(dict: ZstdCompressionDict) -> ZstdDecompressor:
        return ZstdDecompressor(dict)
    @staticmethod
    def zstd_dictionary(dict_data) -> ZstdCompressionDict:
        return ZstdCompressionDict(dict_data, DICT_TYPE_AUTO)
    @staticmethod
    def decompress_block(block, dict: Optional[ZstdCompressionDict], compression_method: int) -> bytes:
        if compression_method == CM_ZLIB:
            try:
                return zlib.decompress(block)
            except zlib.error:
                return block
        else:
            if compression_method == CM_ZSTD or compression_method == CM_ZSTD_DICT:
                if compression_method!= CM_ZSTD_DICT:
                    dict = None
                try:
                    return PakCompression._zstd_decompressor(dict).decompress(block)
                except:
                    return block
            else:
                return block

class TencentPakFile:
    def __init__(self, file_path: PurePath, is_od=False):
        self._file_path = file_path
        self._file_handle = open(file_path, 'rb')
        try:
            import mmap
            self._file_mmap = mmap.mmap(self._file_handle.fileno(), 0, access=mmap.ACCESS_READ)
            self._file_content = memoryview(self._file_mmap)
        except:
            self._file_content = memoryview(self._file_handle.read())
            self._file_mmap = None
        self._is_od = is_od
        self._mount_point = PurePath()
        self._is_zstd_with_dict = 'zsdic' in str(self._file_path)
        self._zstd_dict = None
        self._files = []
        self._index = {}
        self._pak_info = TencentPakInfo(self._file_content, PakCrypto.zuc_keystream())
        self._verify_stem_hash()
        self._tencent_load_index()

    def detect_dominant_style(self) -> dict:
        comp_counter = Counter()
        enc_counter = Counter()
        blk_counter = Counter()
        enc_flag_counter = Counter()
        total = len(self._files)
        if total == 0:
            return {'comp_method': CM_ZSTD, 'enc_method': 0, 'encrypted': False, 'block_size': 0x10000}
        for entry in self._files:
            comp_counter[entry.compression_method] += 1
            if entry.encrypted:
                enc_counter[entry.encryption_method] += 1
                enc_flag_counter['encrypted'] += 1
            else:
                enc_flag_counter['plain'] += 1
            if entry.compression_block_size:
                blk_counter[entry.compression_block_size] += 1
        non_none = [(m,c) for m,c in comp_counter.items() if m != CM_NONE]
        comp_method = max(non_none, key=lambda x: x[1])[0] if non_none else CM_NONE
        encrypted = enc_flag_counter.get('encrypted', 0) > enc_flag_counter.get('plain', 0)
        enc_method = enc_counter.most_common(1)[0][0] if encrypted and enc_counter else 0
        block_size = blk_counter.most_common(1)[0][0] if blk_counter else 0x10000
        return {'comp_method': comp_method, 'enc_method': enc_method, 'encrypted': encrypted, 'block_size': block_size}

    def inject_files(self, inject_plan: list, output_pak: Path, add_signature_marker: bool = True) -> None:
        if not inject_plan:
            raise ValueError('inject_plan is empty — nothing to inject')

        console.print(Panel(
            f'[bold magenta]💉 CUSTOM INJECT[/bold magenta]\n'
            f'[white]Source PAK:[/] [yellow]{self._file_path.name}[/yellow]\n'
            f'[white]Output    :[/] [cyan]{output_pak.name}[/cyan]\n'
            f'[white]Injecting :[/] [green]{len(inject_plan)} new file(s)[/green]\n'
            f'[dim]Credit    : {CREDIT}[/dim]',
            title='INJECT MODE', border_style='magenta', padding=(0, 2)
        ))

        console.print(f'\n[bold magenta]━━ STEP 1/5 : LOADING INJECT FILES ━━  [dim]({CREDIT})[/dim][/bold magenta]')
        work_items = []
        for i, item in enumerate(inject_plan):
            if item.get('plain_bytes') is not None:
                plain = item['plain_bytes']
            elif item.get('src_path') is not None:
                try:
                    plain = Path(item['src_path']).read_bytes()
                except Exception as e:
                    console.print(f'   [red]✗ Cannot read {item["src_path"]}: {e} — skipping[/red]')
                    continue
            else:
                console.print(f'   [red]✗ Inject item {i} has no src_path or plain_bytes — skipping[/red]')
                continue

            internal = item['internal_path'].replace('\\', '/').lstrip('/')
            if not internal:
                console.print(f'   [red]✗ Empty internal_path for item {i} — skipping[/red]')
                continue

            parts = internal.rsplit('/', 1)
            if len(parts) == 2:
                dir_str, file_name = parts[0], parts[1]
            else:
                dir_str, file_name = '', parts[0]

            work_items.append({
                'dir_str':       dir_str,
                'file_name':     file_name,
                'internal_path': internal,
                'plain':         plain,
                'comp_method':   item['comp_method'],
                'enc_method':    item['enc_method'],
                'encrypted':     bool(item['encrypted']),
                'block_size':    item['block_size'],
                'comp_level':    item.get('comp_level', 19),
            })
            console.print(f'   [blue]✨[/] {internal} [dim]({len(plain):,} bytes)[/dim]')

        if not work_items:
            raise RuntimeError('No valid inject items after loading')
        console.print(f'[green]✔ Loaded {len(work_items)} file(s)[/green]')

        console.print(f'\n[bold magenta]━━ STEP 2/5 : ENCODING INJECT FILES ━━  [dim]({CREDIT})[/dim][/bold magenta]')
        keystream = PakCrypto.zuc_keystream()
        version = self._pak_info.version
        header_size = TencentPakInfo._mem_size(version)
        PAK_MAGIC = self._pak_info.magic

        orig_index_offset = self._pak_info.index_offset
        current_new_offset = orig_index_offset
        new_data_region = bytearray()
        new_injected_entries = []

        def _encrypt_plaintext(plaintext, pak_relative_path, encryption_method):
            if PakCrypto._is_simple1_method(encryption_method):
                return bytes(b ^ SIMPLE1_DECRYPT_KEY for b in plaintext)
            elif PakCrypto._is_simple2_method(encryption_method):
                pad = (-len(plaintext)) % SIMPLE2_BLOCK_SIZE
                plaintext += b"\x00" * pad
                key, = struct.unpack("<I", SIMPLE2_DECRYPT_KEY)
                rolling = key
                out = []
                for x, in struct.iter_unpack("<I", plaintext):
                    c = rolling ^ x
                    out.append(c)
                    rolling ^= c
                return struct.pack(f"<{len(out)}I", *out)
            elif PakCrypto._is_sm4_method(encryption_method):
                key = PakCrypto._derive_sm4_key(pak_relative_path, encryption_method)
                sm4 = PakCrypto._sm4_context_for_key(key)
                pad_len = (-len(plaintext)) % 16
                if pad_len > 0:
                    plaintext = plaintext + b'\x00' * pad_len
                out = bytearray()
                for i in range(0, len(plaintext), 16):
                    block = plaintext[i:i+16]
                    if len(block) < 16:
                        block = block.ljust(16, b'\x00')
                    out.extend(sm4.encrypt(block))
                return bytes(out)
            return plaintext

        for item in work_items:
            plain = item['plain']
            comp_method = item['comp_method']
            enc_method = item['enc_method']
            encrypted = item['encrypted']
            block_size_val = item['block_size']
            file_path_for_crypto = PurePath(item['file_name'])

            if len(plain) == 0:
                new_injected_entries.append({
                    'content_hash': SHA1.new(b'').digest(),
                    'offset': current_new_offset,
                    'uncompressed_size': 0, 'size': 0,
                    'comp_method': CM_NONE, 'enc_method': 0, 'encrypted': False,
                    'block_size_val': 0, 'compressed_blocks': [],
                    'unk1': 0, 'unk2': b'\x00' * 20, 'index_new_sep': 0,
                    '_dir_path': PurePath(item['dir_str']) if item['dir_str'] else PurePath(),
                    '_file_name': item['file_name'],
                })
                continue

            if comp_method == CM_NONE:
                if encrypted:
                    aligned_size = PakCrypto.align_encrypted_content_size(len(plain), enc_method)
                    padded = plain + b'\x00' * (aligned_size - len(plain))
                    stored_data = _encrypt_plaintext(padded, file_path_for_crypto, enc_method)
                else:
                    stored_data = plain
                new_size = len(stored_data)
                new_compressed_blocks = []
            else:
                chunks = [plain[i:i+block_size_val] for i in range(0, len(plain), block_size_val)]
                if not chunks: chunks = [b'']
                compressed_chunks = []
                for chunk in chunks:
                    comp = None
                    if comp_method in (CM_ZSTD, CM_ZSTD_DICT):
                        zstd_dict = self._zstd_dict if comp_method == CM_ZSTD_DICT else None
                        for lvl in range(22, 0, -1):
                            try:
                                c = ZstdCompressor(level=lvl, dict_data=zstd_dict, threads=1)
                                comp = c.compress(chunk)
                                break
                            except: continue
                    elif comp_method == CM_ZLIB:
                        comp = zlib.compress(chunk, level=9)
                    if comp is None: comp = chunk
                    compressed_chunks.append(comp)

                encrypted_chunks = []
                for comp_data in compressed_chunks:
                    if encrypted:
                        comp_data = _encrypt_plaintext(comp_data, file_path_for_crypto, enc_method)
                    encrypted_chunks.append(comp_data)

                n_blocks = len(encrypted_chunks)
                indices = PakCrypto.generate_block_indices(n_blocks, enc_method)
                physical_blocks = [None] * n_blocks
                for j, chunk_data in enumerate(encrypted_chunks):
                    physical_blocks[indices[j]] = chunk_data

                physical_offsets = []
                block_cursor = current_new_offset
                for phys_block in physical_blocks:
                    physical_offsets.append((block_cursor, block_cursor + len(phys_block)))
                    block_cursor += len(phys_block)
                new_compressed_blocks = physical_offsets
                stored_data = b''.join(physical_blocks)
                new_size = len(stored_data)
                if encrypted:
                    aligned_total = PakCrypto.align_encrypted_content_size(new_size, enc_method)
                    if aligned_total > new_size:
                        stored_data = stored_data + b'\x00' * (aligned_total - new_size)
                        new_size = aligned_total

            new_content_hash = SHA1.new(stored_data).digest()
            new_data_region.extend(stored_data)

            new_injected_entries.append({
                'content_hash': new_content_hash,
                'offset': current_new_offset,
                'uncompressed_size': len(plain),
                'size': new_size,
                'comp_method': comp_method,
                'enc_method': enc_method if encrypted else 0,
                'encrypted': encrypted,
                'block_size_val': block_size_val,
                'compressed_blocks': new_compressed_blocks,
                'unk1': 0, 'unk2': b'\x00' * 20, 'index_new_sep': 0,
                '_dir_path': PurePath(item['dir_str']) if item['dir_str'] else PurePath(),
                '_file_name': item['file_name'],
            })
            current_new_offset += new_size

        console.print(f'[green]✔ Encoded {len(new_injected_entries)} file(s)[/green]')

        new_entries = []
        entry_to_path = {}
        for dir_path, files in self._index.items():
            for fname, entry in files.items():
                entry_to_path[id(entry)] = (dir_path, fname)
        for i, entry in enumerate(self._files):
            dir_path, fname = entry_to_path.get(id(entry), (PurePath(), f'unknown_{i}'))
            new_entries.append({
                'content_hash': entry.content_hash,
                'offset': entry.offset,
                'uncompressed_size': entry.uncompressed_size,
                'size': entry.size,
                'comp_method': entry.compression_method,
                'enc_method': entry.encryption_method if entry.encrypted else 0,
                'encrypted': entry.encrypted,
                'block_size_val': entry.compression_block_size,
                'compressed_blocks': [(b.start, b.end) for b in entry.compressed_blocks],
                'unk1': entry.unk1, 'unk2': entry.unk2,
                'index_new_sep': entry.index_new_sep,
            })
        new_entries.extend(new_injected_entries)

        if add_signature_marker:
            marker_already_present = False
            for dp, files_dict in self._index.items():
                if dp.name == 'HR_DHAMA' and 'PATCHED.txt' in files_dict:
                    marker_already_present = True
                    break
            if not marker_already_present:
                empty_hash = SHA1.new(b'').digest()
                new_entries.append({
                    'content_hash': empty_hash,
                    'offset': current_new_offset,
                    'uncompressed_size': 0,
                    'size': 0,
                    'comp_method': CM_NONE,
                    'enc_method': 0,
                    'encrypted': False,
                    'block_size_val': 0,
                    'compressed_blocks': [],
                    'unk1': 0,
                    'unk2': b'\x00' * 20,
                    'index_new_sep': 0,
                    '_dir_path': PurePath('L4DXOPxPUBG'),
                    '_file_name': 'PATCHED.txt',
                })

        index_data = bytearray()
        raw_orig_index = self._file_content[self._pak_info.index_offset:][:self._pak_info.index_size]
        orig_index_decoded = PakCrypto.decrypt_index(bytes(raw_orig_index), self._pak_info)
        orig_reader = Reader(orig_index_decoded)
        orig_mount_len = orig_reader.i4()
        orig_mount_bytes = bytes(orig_reader.s(orig_mount_len))
        index_data.extend(struct.pack('<I', orig_mount_len))
        index_data.extend(orig_mount_bytes)
        index_data.extend(struct.pack('<I', len(new_entries)))

        for item in new_entries:
            index_data.extend(item['content_hash'])
            if version <= 1: index_data.extend(struct.pack('<Q', 0))
            index_data.extend(struct.pack('<Q', item['offset']))
            index_data.extend(struct.pack('<Q', item['uncompressed_size']))
            index_data.extend(struct.pack('<I', item['comp_method'] & CM_MASK))
            index_data.extend(struct.pack('<Q', item['size']))
            if version >= 5:
                index_data.extend(struct.pack('<B', item['unk1']))
                index_data.extend(item['unk2'] if item['unk2'] else b'\x00' * 20)
            if item['comp_method'] != CM_NONE and version >= 3:
                index_data.extend(struct.pack('<I', len(item['compressed_blocks'])))
                for (start, end) in item['compressed_blocks']:
                    index_data.extend(struct.pack('<Q', start))
                    index_data.extend(struct.pack('<Q', end))
            if version >= 4:
                index_data.extend(struct.pack('<I', item['block_size_val']))
                index_data.extend(struct.pack('<B', 1 if item['encrypted'] else 0))
            if version >= 12:
                index_data.extend(struct.pack('<I', item['enc_method']))
                index_data.extend(struct.pack('<I', item['index_new_sep']))

        file_to_dirname = {}
        for dir_path, files_dict in self._index.items():
            dir_str = dir_path.as_posix()
            for fname, entry in files_dict.items():
                for i, fe in enumerate(self._files):
                    if id(fe) == id(entry):
                        file_to_dirname[i] = (dir_str, fname)
                        break
        for i, item in enumerate(new_entries):
            if i not in file_to_dirname:
                if '_dir_path' in item:
                    file_to_dirname[i] = (item['_dir_path'].as_posix(), item['_file_name'])
                else:
                    file_to_dirname[i] = ('', f'file_{i}')

        all_dirs = []
        dir_to_files = {}
        for dir_path in self._index.keys():
            ds = dir_path.as_posix()
            all_dirs.append(ds)
            dir_to_files[ds] = []
        for i, item in enumerate(new_entries):
            ds, fn = file_to_dirname[i]
            if ds not in dir_to_files:
                dir_to_files[ds] = []
                all_dirs.append(ds)
            dir_to_files[ds].append((fn, i))

        index_data.extend(struct.pack('<Q', len(all_dirs)))
        for dir_str in all_dirs:
            files_list = dir_to_files[dir_str]
            if not dir_str or dir_str == '.':
                index_data.extend(struct.pack('<I', 0))
            else:
                if not dir_str.endswith('/'): dir_str_with_slash = dir_str + '/'
                else: dir_str_with_slash = dir_str
                dir_bytes = dir_str_with_slash.encode('utf-8') + b'\x00'
                index_data.extend(struct.pack('<I', len(dir_bytes)))
                index_data.extend(dir_bytes)
            index_data.extend(struct.pack('<Q', len(files_list)))
            for file_name, fi in files_list:
                name_bytes = file_name.encode('utf-8') + b'\x00'
                index_data.extend(struct.pack('<I', len(name_bytes)))
                index_data.extend(name_bytes)
                index_data.extend(struct.pack('<i', -fi - 1))
        index_data.extend(b'\x1d\x00\x00\x00\x2e\x2e')

        index_hash = SHA1.new(bytes(index_data)).digest()

        if version > 7 and self._pak_info.index_encrypted:
            key = PakCrypto.rsa_extract(self._pak_info.packed_key, RSA_MOD_1)
            iv = PakCrypto.rsa_extract(self._pak_info.packed_iv, RSA_MOD_1)
            assert len(key) == 32 and len(iv) == 32
            padded = pad(bytes(index_data), AES.block_size)
            aes = AES.new(key, MODE_CBC, iv[:16])
            encrypted_index = aes.encrypt(padded)
        elif self._pak_info.index_encrypted:
            encrypted_index = bytes(b ^ SIMPLE1_DECRYPT_KEY for b in bytes(index_data))
        else:
            encrypted_index = bytes(index_data)

        index_size = len(encrypted_index)
        new_index_offset = orig_index_offset + len(new_data_region)

        encrypted_magic = PAK_MAGIC ^ keystream[2]
        key_stream_hash = struct.pack('<5I', *keystream[4:][:5])
        encrypted_index_hash = bytes(a ^ b for a, b in zip(index_hash, key_stream_hash))
        encrypted_index_size = index_size ^ ((keystream[10] << 32) | keystream[11])
        encrypted_index_offset = new_index_offset ^ ((keystream[0] << 32) | keystream[1])
        encrypted_flag_byte = (1 if self._pak_info.index_encrypted else 0) ^ (keystream[3] & 0xFF)

        orig_data_region = bytearray(self._file_content[0:orig_index_offset])
        output_pak.parent.mkdir(parents=True, exist_ok=True)
        with open(output_pak, 'wb') as f:
            f.write(bytes(orig_data_region))
            f.write(bytes(new_data_region))
            f.write(encrypted_index)
            if version >= 7:
                key_unk1 = struct.pack('<8I', *keystream[7:][:8])
                unk1_plain = self._pak_info.unk1 if self._pak_info.unk1 else b'\x00' * 32
                encrypted_unk1 = bytes(a ^ b for a, b in zip(unk1_plain, key_unk1))
                f.write(encrypted_unk1)
            if version >= 8:
                f.write(self._pak_info.packed_key if self._pak_info.packed_key else b'\x00' * 256)
                f.write(self._pak_info.packed_iv if self._pak_info.packed_iv else b'\x00' * 256)
                f.write(self._pak_info.packed_index_hash if self._pak_info.packed_index_hash else b'\x00' * 256)
            if version >= 9:
                f.write(struct.pack('<I', (self._pak_info.stem_hash or 0) ^ keystream[8]))
                f.write(struct.pack('<I', (self._pak_info.unk2 or 0) ^ keystream[9]))
            if version >= 12:
                f.write(self._pak_info.content_org_hash if self._pak_info.content_org_hash else b'\x00' * 20)
            f.write(struct.pack('<B', encrypted_flag_byte))
            f.write(struct.pack('<I', encrypted_magic))
            f.write(struct.pack('<I', version))
            if version >= 6:
                f.write(encrypted_index_hash)
            else:
                f.write(b'\x00' * 20)
            f.write(struct.pack('<Q', encrypted_index_size))
            f.write(struct.pack('<Q', encrypted_index_offset))

        console.print(Panel(
            f'[bold green]🎉 INJECT COMPLETE![/bold green]\n\n'
            f'[white]Output  :[/] [cyan]{output_pak.name}[/cyan]\n'
            f'[dim]Credit  : {CREDIT}[/dim]',
            title='✅ SUCCESS', border_style='green', padding=(1, 2)
        ))

    def _get_method_str(self, method_int, is_encryption):
        if is_encryption:
            if PakCrypto._is_simple1_method(method_int): return "SIMPLE1"
            if PakCrypto._is_simple2_method(method_int): return "SIMPLE2"
            if PakCrypto._is_sm4_method(method_int): return f"SM4 (Type {method_int})"
            return "NONE" if method_int == 0 else "UNKNOWN"
        else:
            if method_int == CM_NONE: return "NONE"
            if method_int == CM_ZLIB: return "ZLIB"
            if method_int == CM_ZSTD: return "ZSTD"
            if method_int == CM_ZSTD_DICT: return "ZSTD_DICT"
            return "UNKNOWN"

    def _verify_stem_hash(self) -> None:
        if not self._is_od and self._pak_info.version >= 9:
            expected = zlib.crc32(self._file_path.stem.encode('utf-32le'))
            if self._pak_info.stem_hash != expected:
                console.print('[yellow]Stem hash mismatch (file may be renamed)[/yellow]')
    def _tencent_load_index(self) -> None:
        index_data = self._file_content[self._pak_info.index_offset:][:self._pak_info.index_size]
        if self._pak_info.index_encrypted:
            try:
                index_data = PakCrypto.decrypt_index(index_data, self._pak_info)
            except Exception:
                console.print('[yellow]Index decryption failed, trying raw[/yellow]')
        self._verify_index_hash(index_data)
        self._load_index(index_data)
    def _verify_index_hash(self, index_data) -> None:
        expected_hash = self._pak_info.index_hash
        if not self._is_od and self._pak_info.version >= 8:
            try:
                rsa_hash = PakCrypto.rsa_extract(self._pak_info.packed_index_hash, RSA_MOD_2)
                if expected_hash != rsa_hash:
                    console.print(f'[yellow]SECURE VIP CONNECTION  [dim]({CREDIT})[/dim][/yellow]')
            except:
                pass
        actual = SHA1.new(index_data).digest()
        if expected_hash != actual:
            console.print('[yellow]Index hash mismatch (PAK modified?)[/yellow]')
    @staticmethod
    def _construct_mount_point(mount_point: str) -> PurePath:
        result = PurePath()
        for part in PurePath(mount_point).parts:
            if part!= '..':
                result /= part
        return result
    def _peek_content(self, offset: int, size: int, encryption_method: int) -> memoryview:
        size = PakCrypto.align_encrypted_content_size(size, encryption_method)
        end = min(offset + size, len(self._file_content))
        return self._file_content[offset:end]
    def _peek_block_content(self, block: PakCompressedBlock, encryption_method: int) -> memoryview:
        size = PakCrypto.align_encrypted_content_size(block.end - block.start, encryption_method)
        end = min(block.start + size, len(self._file_content))
        return self._file_content[block.start:end]
    def _construct_zstd_dict(self, dict_entry: TencentPakEntry) -> None:
        assert not self._zstd_dict
        assert not dict_entry.encrypted
        assert dict_entry.compression_method == CM_NONE
        reader = Reader(self._peek_content(dict_entry.offset, dict_entry.size, 0))
        dict_size = reader.u8()
        _ = reader.u4()
        assert dict_size == reader.u4()
        dict_data = reader.s(dict_size)
        self._zstd_dict = PakCompression.zstd_dictionary(dict_data)
    def _load_index(self, index_data) -> None:
        if self._pak_info.version <= 10:
            raise ValueError(f'Unsupported version: {self._pak_info.version}')
        else:
            reader = Reader(index_data)
            self._mount_point = self._construct_mount_point(reader.string())
            num_files = reader.u4()
            self._files = []
            for _ in range(num_files):
                self._files.append(TencentPakEntry(reader, self._pak_info.version))
            num_dirs = reader.u8()
            for _ in range(num_dirs):
                dir_path = PurePath(reader.string())
                num_entries = reader.u8()
                dir_content = {}
                for _ in range(num_entries):
                    entry_name = reader.string()
                    idx = reader.i4()
                    if idx < 0:
                        entry_idx = ~idx
                        if 0 <= entry_idx < len(self._files):
                            dir_content[entry_name] = self._files[entry_idx]
                if self._is_zstd_with_dict and dir_path.name == 'zstddic':
                    if len(dir_content) == 1:
                        self._construct_zstd_dict(list(dir_content.values())[0])
                else:
                    if dir_content:
                        self._index[dir_path] = dir_content

    def _write_to_disk(self, file_path: Path, entry: TencentPakEntry) -> None:
        encryption_method = entry.encryption_method
        compression_method = entry.compression_method
        total_blocks = len(entry.compressed_blocks)

        if compression_method == CM_NONE:
            data = self._peek_content(entry.offset, entry.size, encryption_method)
            if entry.encrypted:
                data = PakCrypto.decrypt_block(data, file_path, encryption_method)
            with open(file_path, 'wb') as f:
                f.write(data)
            return

        with open(file_path, 'wb') as f:
            for idx in PakCrypto.generate_block_indices(total_blocks, encryption_method):
                if idx >= len(entry.compressed_blocks):
                    continue
                block = entry.compressed_blocks[idx]
                data = self._peek_block_content(block, encryption_method)
                if entry.encrypted:
                    try:
                        data = PakCrypto.decrypt_block(data, file_path, encryption_method)
                    except:
                        pass
                try:
                    decompressed = PakCompression.decompress_block(data, self._zstd_dict, compression_method)
                except:
                    decompressed = data
                f.write(decompressed)

    def dump(self, out_path: Path) -> None:
        mp_parts = [_sanitize_part(p) for p in self._mount_point.parts]
        out_path = out_path.joinpath(*mp_parts) if mp_parts else out_path
        out_path.mkdir(parents=True, exist_ok=True)
        total_files = sum(len(d) for d in self._index.values())

        with Progress(
            SpinnerColumn(),
            TextColumn(f"[white][UNPACK][/] {{task.description}}  [dim]({CREDIT})[/dim]"),
            BarColumn(),
            TaskProgressColumn(),
            TimeElapsedColumn(),
            console=console
        ) as progress:
            task = progress.add_task("Extracting files...", total=total_files)
            for dir_path, dir_content in self._index.items():
                dp_parts = [_sanitize_part(p) for p in dir_path.parts]
                current_out_path = out_path.joinpath(*dp_parts) if dp_parts else out_path
                current_out_path.mkdir(parents=True, exist_ok=True)
                for file_name, entry in dir_content.items():
                    safe_name = _sanitize_part(file_name)
                    try:
                        self._write_to_disk(current_out_path / safe_name, entry)
                    except Exception as e:
                        console.print(f'[yellow]  Skipped {safe_name}: {e}[/yellow]')
                    progress.update(task, advance=1)

    def __del__(self):
        if hasattr(self, '_file_handle'):
            try:
                self._file_handle.close()
            except:
                pass

_INVALID_FN_CHARS = re.compile(r'[\x00-\x1f<>:"/\\|?*\x7f]')

def _sanitize_part(name) -> str:
    if name is None:
        return '_'
    s = str(name)
    s = s.replace('\x00', '')
    s = _INVALID_FN_CHARS.sub('', s)
    s = s.rstrip('. ')
    if not s or s in ('.', '..'):
        s = '_'
    return s

def _encrypt_plaintext(plaintext: bytes, pak_relative_path: PurePath, encryption_method: int) -> bytes:
    if PakCrypto._is_simple1_method(encryption_method):
        return bytes((b ^ SIMPLE1_DECRYPT_KEY for b in plaintext))
    else:
        if PakCrypto._is_simple2_method(encryption_method):
            pad = -len(plaintext) % SIMPLE2_BLOCK_SIZE
            plaintext += b'\x00' * pad
            key, = struct.unpack('<I', SIMPLE2_DECRYPT_KEY)
            rolling = key
            out = []
            for x, in struct.iter_unpack('<I', plaintext):
                c = rolling ^ x
                out.append(c)
                rolling ^= c
            return struct.pack(f'<{len(out)}I', *out)
        else:
            if PakCrypto._is_sm4_method(encryption_method):
                key = PakCrypto._derive_sm4_key(pak_relative_path, encryption_method)
                sm4 = PakCrypto._sm4_context_for_key(key)
                pad_len = -len(plaintext) % 16
                if pad_len > 0:
                    plaintext = plaintext + b'\x00' * pad_len
                out = bytearray()
                for i in range(0, len(plaintext), 16):
                    block = plaintext[i:i + 16]
                    if len(block) < 16:
                        block = block.ljust(16, b'\x00')
                    out.extend(sm4.encrypt(block))
                return bytes(out)
            else:
                return plaintext

def _best_compress(chunk, cm, zstd_dict=None):
    if cm == CM_ZLIB:
        return zlib.compress(chunk, 9)
    if cm in (CM_ZSTD, CM_ZSTD_DICT):
        zd = zstd_dict if cm == CM_ZSTD_DICT else None
        for lvl in [22, 19, 16, 13, 10, 7, 4, 1]:
            try:
                return ZstdCompressor(level=lvl, dict_data=zd, threads=1).compress(chunk)
            except Exception:
                continue
    return chunk

def _block_permutation(n_chunks: int, encryption_method: int):
    return PakCrypto.generate_block_indices(n_chunks, encryption_method)

def _pw_string(s):
    if not s: return struct.pack('<i', 0)
    b = s.encode('utf-8') + b'\x00'
    return struct.pack('<i', len(b)) + b

def _pw_entry(e, v):
    w = bytearray(e.content_hash)
    w += struct.pack('<Q', e.offset)
    w += struct.pack('<Q', e.uncompressed_size)
    w += struct.pack('<I', e.compression_method)
    w += struct.pack('<Q', e.size)
    if v >= 5:
        w += bytes([e.unk1])
        w += e.unk2
    if e.compression_method != CM_NONE and v >= 3:
        w += struct.pack('<I', len(e.compressed_blocks))
        for b in e.compressed_blocks:
            w += struct.pack('<QQ', b.start, b.end)
    if v >= 4:
        w += struct.pack('<I', e.compression_block_size)
        w += bytes([1 if e.encrypted else 0])
    if v >= 12:
        w += struct.pack('<II', e.encryption_method, e.index_new_sep)
    return bytes(w)

def _get_all_dirs_and_mp(pak_file):
    raw = bytes(pak_file._file_content[
        pak_file._pak_info.index_offset:][:pak_file._pak_info.index_size])
    if pak_file._pak_info.index_encrypted:
        try:
            raw = PakCrypto.decrypt_index(raw, pak_file._pak_info)
        except:
            pass
    r = Reader(raw)
    mp = r.string()
    num_files = r.u4()
    for _ in range(num_files):
        TencentPakEntry(r, pak_file._pak_info.version)
    dirs = {}
    for _ in range(r.u8()):
        dp = r.string()
        cnt = r.u8()
        d = {}
        for _ in range(cnt):
            fname = r.string()
            idx = ~r.i4()
            if 0 <= idx < len(pak_file._files):
                d[fname] = (idx, pak_file._files[idx])
        dirs[dp] = d
    return mp, dirs

def repack_pak_file_full(pak_file, edited_root, output_path, target_path=None, force_add=False, path_map=None):
    import copy as _cp
    edit_files = [p for p in Path(edited_root).rglob('*') if p.is_file()]
    if not edit_files:
        console.print(f'[red]No files in EDIT folder.  [dim]({CREDIT})[/dim][/]')
        return 0
    version = pak_file._pak_info.version
    keystream = PakCrypto.zuc_keystream()
    orig_fc = pak_file._file_content
    mp_str, all_dirs = _get_all_dirs_and_mp(pak_file)

    def _norm_dir(tp):
        if not tp:
            return None
        tp = tp.replace('\\', '/')
        matched_dir = None
        for existing_dir in all_dirs.keys():
            if existing_dir.strip('/').lower() == tp.strip('/').lower():
                matched_dir = existing_dir
                break
        return matched_dir if matched_dir else (tp.strip('/') + '/')

    if target_path:
        target_path = _norm_dir(target_path)
    norm_path_map = {}
    if path_map:
        for _name, _tp in path_map.items():
            norm_path_map[_name] = _norm_dir(_tp)

    pak_name_map = {}
    for dp_str, dir_files in all_dirs.items():
        for name, (slot, entry) in dir_files.items():
            full_path = str(PurePath(dp_str) / name).replace('\\', '/')
            pak_name_map.setdefault(name.lower(), []).append((full_path, slot, entry))

    edited = {}
    for p in edit_files:
        fl = p.name.lower()
        found_match = False
        if path_map is not None:
            tp = norm_path_map.get(p.name)
        else:
            tp = target_path

        if not found_match:
            rel_path = p.relative_to(edited_root).as_posix()
            mp_norm = mp_str.strip('/')
            if mp_norm and rel_path.startswith(mp_norm + '/'):
                rel_path = rel_path[len(mp_norm) + 1:]
            for dp_str, dir_files in all_dirs.items():
                for name, (slot, entry) in dir_files.items():
                    full_path = str(PurePath(dp_str) / name).replace('\\', '/')
                    if full_path == rel_path or full_path.endswith('/' + rel_path) or rel_path.endswith('/' + name):
                        edited[full_path] = (p, slot, entry, False)
                        found_match = True
                        break
                if found_match:
                    break

        if fl in pak_name_map:
            cands = pak_name_map[fl]
            if tp:
                target_cands = [(fp, s, e) for fp, s, e in cands if tp.strip('/') in fp]
                if target_cands:
                    sz = p.stat().st_size
                    sm = [(fp, s, e) for fp, s, e in target_cands if e.uncompressed_size == sz]
                    fp, s, e = sm[0] if sm else target_cands[0]
                    edited[fp] = (p, s, e, False)
                    found_match = True
            if not found_match:
                sz = p.stat().st_size
                sm = [(fp, s, e) for fp, s, e in cands if e.uncompressed_size == sz]
                if sm:
                    fp, s, e = sm[0]
                else:
                    fp, s, e = cands[0]
                if tp and force_add:
                    new_fp = f"{tp.rstrip('/')}/{p.name}"
                    edited[new_fp] = (p, s, e, True)
                else:
                    edited[fp] = (p, s, e, False)
                found_match = True

        if not found_match:
            stem = p.stem.lower()
            ext = p.suffix.lower()
            for dp_str, dir_files in all_dirs.items():
                for name, (slot, entry) in dir_files.items():
                    if Path(name).stem.lower() == stem and Path(name).suffix.lower() == ext:
                        full_path = str(PurePath(dp_str) / name).replace('\\', '/')
                        if tp and force_add:
                            new_fp = f"{tp.rstrip('/')}/{p.name}"
                            edited[new_fp] = (p, slot, entry, True)
                        else:
                            edited[full_path] = (p, slot, entry, False)
                        found_match = True
                        break
                if found_match:
                    break

        if not found_match and force_add:
            template_entry = None
            for dp_str, dir_files in all_dirs.items():
                for _n, (_s, e) in dir_files.items():
                    if Path(_n).suffix.lower() == p.suffix.lower():
                        template_entry = e
                        break
                if template_entry:
                    break
            if not template_entry:
                for dp_str, dir_files in all_dirs.items():
                    for _n, (_s, e) in dir_files.items():
                        template_entry = e
                        break
                    if template_entry:
                        break
            rel_path = p.relative_to(edited_root).as_posix()
            mp_norm = mp_str.strip('/')
            if mp_norm and rel_path.startswith(mp_norm + '/'):
                rel_path = rel_path[len(mp_norm) + 1:]
            if tp:
                new_fp = f"{tp.rstrip('/')}/{p.name}"
            else:
                new_fp = rel_path
            if template_entry:
                edited[new_fp] = (p, -1, template_entry, True)
                found_match = True
            else:
                console.print(f'[yellow]~ Skipped (no entry in PAK): {p.name}  [dim]({CREDIT})[/dim][/]')

    if not edited:
        console.print(f'[red]No files to repack!  [dim]({CREDIT})[/dim][/]')
        return 0

    slot_to_new = {}
    for i, e in enumerate(pak_file._files):
        ne = _cp.copy(e)
        ne.compressed_blocks = [_cp.copy(b) for b in e.compressed_blocks]
        slot_to_new[i] = ne

    import tempfile as _tmpfile
    _tmpfd, _tmppath = _tmpfile.mkstemp(suffix='.pak')
    _outf = open(_tmpfd, 'r+b')
    _pos = [0]

    file_rows = []
    new_added = []
    processed_count = 0
    total_to_process = sum(len(files) for files in all_dirs.values())

    def _out_append(data: bytes):
        start = _pos[0]
        _outf.write(data)
        _pos[0] += len(data)
        return start

    def _out_len() -> int:
        return _pos[0]

    for dp_str, dir_files in list(all_dirs.items()):
        for name, (slot, old_entry) in list(dir_files.items()):
            full_path = str(PurePath(dp_str) / name).replace('\\', '/')
            ne = slot_to_new[slot]
            em = old_entry.encryption_method
            cm = old_entry.compression_method

            if full_path in edited:
                p, _s, template, is_new = edited[full_path]
                new_raw = p.read_bytes()
                pak_rel = PurePath(full_path)

                ne.uncompressed_size = len(new_raw)
                ne.compression_method = cm
                ne.encryption_method = em
                ne.encrypted = old_entry.encrypted
                ne.unk1 = old_entry.unk1
                ne.index_new_sep = old_entry.index_new_sep

                if is_new and (target_path or path_map):
                    full_path_str = mp_str + full_path
                    ne.unk2 = SHA1.new(full_path_str.lower().encode('utf-8')).digest()
                else:
                    ne.unk2 = old_entry.unk2

                stored_start = _out_len()
                if cm == CM_NONE:
                    cipher = (_encrypt_plaintext(new_raw, pak_rel, em) if ne.encrypted else new_raw)
                    ne.offset = _out_len()
                    ne.size = len(new_raw)
                    _out_append(cipher)
                else:
                    cs = (old_entry.compression_block_size if old_entry.compression_block_size > 0 else 65536)
                    chunks = [new_raw[i:i + cs] for i in range(0, len(new_raw), cs)]
                    order = _block_permutation(len(chunks), em)
                    cipher_by_logical = []
                    for chunk in chunks:
                        compressed = _best_compress(chunk, cm, pak_file._zstd_dict)
                        cipher = (_encrypt_plaintext(compressed, pak_rel, em) if ne.encrypted else compressed)
                        cipher_by_logical.append(cipher)
                    inv = [0] * len(chunks)
                    for logical_i, phys_i in enumerate(order):
                        inv[phys_i] = logical_i
                    new_blks = [None] * len(chunks)
                    for phys_i in range(len(chunks)):
                        blk = PakCompressedBlock.__new__(PakCompressedBlock)
                        blk.start = _out_len()
                        _out_append(cipher_by_logical[inv[phys_i]])
                        blk.end = _out_len()
                        new_blks[phys_i] = blk
                    ne.compressed_blocks = new_blks
                    ne.offset = new_blks[0].start if new_blks else _out_len()
                    ne.size = sum(b.end - b.start for b in new_blks)

                _outf.seek(stored_start)
                stored_bytes = _outf.read(ne.size)
                _outf.seek(0, 2)
                ne.content_hash = SHA1.new(stored_bytes).digest()

                file_rows.append((full_path, len(new_raw), ne.size))
                processed_count += 1
                if processed_count % 5 == 0 or processed_count == total_to_process:
                    sys.stdout.write(f'\r[white]  Processing Assets... [{processed_count}/{total_to_process}]  · {CREDIT}[/]')
                    sys.stdout.flush()
            else:
                if cm == CM_NONE:
                    read_sz = (PakCrypto.align_encrypted_content_size(old_entry.size, em)
                               if old_entry.encrypted else old_entry.size)
                    ne.offset = _out_len()
                    _out_append(bytes(orig_fc[old_entry.offset: old_entry.offset + read_sz]))
                elif old_entry.compressed_blocks:
                    new_blks = []
                    for ob in old_entry.compressed_blocks:
                        unc = ob.end - ob.start
                        enc = (PakCrypto.align_encrypted_content_size(unc, em)
                               if old_entry.encrypted else unc)
                        nb = PakCompressedBlock.__new__(PakCompressedBlock)
                        nb.start = _out_len()
                        _out_append(bytes(orig_fc[ob.start: ob.start + enc]))
                        nb.end = _out_len()
                        new_blks.append(nb)
                    ne.compressed_blocks = new_blks
                    ne.offset = new_blks[0].start if new_blks else _out_len()

    sys.stdout.write(f'\r  All {processed_count} assets processed.  · {CREDIT}          \n')
    sys.stdout.flush()

    if force_add:
        for fp, (p, slot, template, is_new) in edited.items():
            if not is_new or slot >= 0:
                continue
            already = False
            for dp_str, dir_files in all_dirs.items():
                for _n, (_s, _e) in dir_files.items():
                    if str(PurePath(dp_str) / _n).replace('\\', '/') == fp:
                        already = True
                        break
                if already:
                    break
            if already:
                continue

            ne = _cp.copy(template)
            new_raw = p.read_bytes()
            pak_rel = PurePath(fp)
            ne.uncompressed_size = len(new_raw)
            ne.compression_method = template.compression_method
            ne.compressed_blocks = []
            ne.compression_block_size = template.compression_block_size
            ne.encryption_method = template.encryption_method
            ne.encrypted = template.encrypted
            ne.unk1 = template.unk1
            full_path_str = mp_str + fp
            ne.unk2 = SHA1.new(full_path_str.lower().encode('utf-8')).digest()
            ne.index_new_sep = template.index_new_sep

            stored_start = _out_len()
            if ne.compression_method == CM_NONE:
                cipher = (_encrypt_plaintext(new_raw, pak_rel, ne.encryption_method) if ne.encrypted else new_raw)
                ne.offset = _out_len()
                ne.size = len(new_raw)
                _out_append(cipher)
            else:
                cs = template.compression_block_size if template.compression_block_size > 0 else 65536
                chunks = [new_raw[i:i + cs] for i in range(0, len(new_raw), cs)]
                order = _block_permutation(len(chunks), ne.encryption_method)
                cipher_by_logical = []
                for chunk in chunks:
                    compressed = _best_compress(chunk, ne.compression_method, pak_file._zstd_dict)
                    cipher = (_encrypt_plaintext(compressed, pak_rel, ne.encryption_method) if ne.encrypted else compressed)
                    cipher_by_logical.append(cipher)
                inv = [0] * len(chunks)
                for logical_i, phys_i in enumerate(order):
                    inv[phys_i] = logical_i
                new_blks = [None] * len(chunks)
                for phys_i in range(len(chunks)):
                    blk = PakCompressedBlock.__new__(PakCompressedBlock)
                    blk.start = _out_len()
                    _out_append(cipher_by_logical[inv[phys_i]])
                    blk.end = _out_len()
                    new_blks[phys_i] = blk
                ne.compressed_blocks = new_blks
                ne.offset = new_blks[0].start if new_blks else _out_len()
                ne.size = sum(b.end - b.start for b in new_blks)

            _outf.seek(stored_start)
            stored_bytes = _outf.read(ne.size)
            _outf.seek(0, 2)
            ne.content_hash = SHA1.new(stored_bytes).digest()

            if path_map is not None:
                _nk = norm_path_map.get(p.name)
                _dir_key = _nk if _nk else ''
            else:
                _dir_key = target_path
            new_slot = len(slot_to_new) + len(new_added)
            new_added.append((_dir_key, p.name, ne, new_slot))
            file_rows.append((fp, len(new_raw), ne.size))

    max_slot = max(slot_to_new.keys()) if slot_to_new else -1
    new_files = [slot_to_new[i] for i in range(max_slot + 1)]
    dir_to_added = {}
    for dir_key, name, ne, new_slot in new_added:
        new_files.append(ne)
        dir_to_added.setdefault(dir_key, []).append((name, ne, new_slot))

    for dir_key, items in dir_to_added.items():
        if dir_key not in all_dirs:
            all_dirs[dir_key] = {}
        for name, ne, new_slot in items:
            all_dirs[dir_key][name] = (new_slot, ne)

    idx = bytearray(_pw_string(mp_str))
    idx += struct.pack('<I', len(new_files))
    for ne in new_files:
        idx += _pw_entry(ne, version)
    idx += struct.pack('<Q', len(all_dirs))
    for dp_str, dir_files in all_dirs.items():
        idx += _pw_string(dp_str)
        idx += struct.pack('<Q', len(dir_files))
        for name, (slot, _old_e) in dir_files.items():
            idx += _pw_string(name)
            idx += struct.pack('<i', ~slot)

    index_plain = bytes(idx)
    new_sha1 = SHA1.new(index_plain).digest()

    if pak_file._pak_info.index_encrypted:
        try:
            key = PakCrypto.rsa_extract(pak_file._pak_info.packed_key, RSA_MOD_1)
            iv = PakCrypto.rsa_extract(pak_file._pak_info.packed_iv, RSA_MOD_1)
            if key and iv and len(key) == 32 and len(iv) >= 16:
                aes = AES.new(key, MODE_CBC, iv[:16])
                pad = (-len(index_plain)) % AES.block_size or AES.block_size
                index_bytes = aes.encrypt(index_plain + bytes([pad] * pad))
            else:
                index_bytes = index_plain
        except:
            index_bytes = index_plain
    else:
        index_bytes = index_plain

    new_idx_offset = _out_len()
    new_idx_size = len(index_bytes)
    _out_append(index_bytes)

    footer_sz = TencentPakInfo._mem_size(version)
    new_footer = bytearray(orig_fc[-footer_sz:])
    h_key = struct.pack('<5I', *keystream[4:9])
    new_footer[-36:-16] = bytes(a ^ b for a, b in zip(new_sha1, h_key))
    new_footer[-16:-8] = ((new_idx_size ^ (keystream[10] << 32 | keystream[11])).to_bytes(8, 'little'))
    new_footer[-8:] = ((new_idx_offset ^ (keystream[0] << 32 | keystream[1])).to_bytes(8, 'little'))
    _out_append(new_footer)

    _outf.flush()
    _outf.close()
    shutil.copy2(_tmppath, output_path)
    os.unlink(_tmppath)

    if file_rows:
        summary = Table(title=f"Files Processed  · {CREDIT}", box=ROUNDED, border_style="white")
        summary.add_column("Path in PAK", style="white")
        summary.add_column("Original Size", justify="right", style="dim")
        summary.add_column("Stored Size", justify="right", style="dim")
        for fp, orig_sz, stored_sz in file_rows:
            summary.add_row(fp, human_size(orig_sz), human_size(stored_sz))
        console.print(summary)

    return len(edited)

def build_new_pak_from_template(template_pak_path: Path, edit_dir: Path, output_path: Path, target_path: str = None, path_map: dict = None):
    import copy as _cp
    console.print(f'[white]Building NEW PAK using template: {template_pak_path.name}  [dim]· {CREDIT}[/dim][/]')
    pak_file = TencentPakFile(template_pak_path, is_od=True)
    version = pak_file._pak_info.version
    keystream = PakCrypto.zuc_keystream()
    mp_str, _all_dirs_orig = _get_all_dirs_and_mp(pak_file)

    template_entry = None
    for _dir_path, files in pak_file._index.items():
        for _name, entry in files.items():
            template_entry = entry
            break
        if template_entry:
            break
    if template_entry is None:
        console.print(f'[red]No file found in the Template PAK to copy settings from!  [dim]({CREDIT})[/dim][/]')
        return 0

    edit_files = [p for p in Path(edit_dir).rglob('*') if p.is_file()]
    if not edit_files:
        console.print(f'[red]No file found in the EDIT folder!  [dim]({CREDIT})[/dim][/]')
        return 0

    out_buf = bytearray()
    new_files = []
    all_dirs = {}
    file_rows = []

    with Progress(
        SpinnerColumn(),
        TextColumn(f"[white][BUILD][/] {{task.description}}  [dim]({CREDIT})[/dim]"),
        BarColumn(),
        TaskProgressColumn(),
        TimeElapsedColumn(),
        console=console
    ) as progress:
        task = progress.add_task("Adding files...", total=len(edit_files))

        for p in edit_files:
            rel = p.relative_to(edit_dir).as_posix()
            if path_map is not None:
                tp_for_file = path_map.get(p.name)
                if tp_for_file is None:
                    tp_for_file = ''
                if tp_for_file == '':
                    parent = str(PurePath(rel).parent).replace('\\', '/')
                    dir_key = '' if parent == '.' else parent + '/'
                    fp = rel
                else:
                    dir_key = tp_for_file.rstrip('/') + '/'
                    fp = f"{tp_for_file.rstrip('/')}/{p.name}"
            elif target_path:
                fp = f"{target_path.rstrip('/')}/{p.name}"
                dir_key = target_path.rstrip('/') + '/'
            else:
                parent = str(PurePath(rel).parent).replace('\\', '/')
                dir_key = '' if parent == '.' else parent + '/'
                fp = rel

            ne = _cp.copy(template_entry)
            new_raw = p.read_bytes()
            pak_rel = PurePath(fp)

            ne.uncompressed_size = len(new_raw)
            ne.compression_method = template_entry.compression_method
            ne.encryption_method = template_entry.encryption_method
            ne.encrypted = template_entry.encrypted
            ne.unk1 = template_entry.unk1
            full_path_str = mp_str + fp
            ne.unk2 = SHA1.new(full_path_str.lower().encode('utf-8')).digest()
            ne.index_new_sep = template_entry.index_new_sep

            stored_start = len(out_buf)
            if ne.compression_method == CM_NONE:
                cipher = (_encrypt_plaintext(new_raw, pak_rel, ne.encryption_method)
                          if ne.encrypted else new_raw)
                ne.offset = len(out_buf)
                ne.size = len(new_raw)
                out_buf += cipher
            else:
                cs = template_entry.compression_block_size if template_entry.compression_block_size > 0 else 65536
                chunks = [new_raw[i:i + cs] for i in range(0, len(new_raw), cs)]
                order = _block_permutation(len(chunks), ne.encryption_method)
                cipher_by_logical = []
                for chunk in chunks:
                    compressed = _best_compress(chunk, ne.compression_method, pak_file._zstd_dict)
                    cipher = (_encrypt_plaintext(compressed, pak_rel, ne.encryption_method)
                              if ne.encrypted else compressed)
                    cipher_by_logical.append(cipher)
                inv = [0] * len(chunks)
                for logical_i, phys_i in enumerate(order):
                    inv[phys_i] = logical_i
                new_blks = [None] * len(chunks)
                for phys_i in range(len(chunks)):
                    blk = PakCompressedBlock.__new__(PakCompressedBlock)
                    blk.start = len(out_buf)
                    blk.end = blk.start + len(cipher_by_logical[inv[phys_i]])
                    out_buf += cipher_by_logical[inv[phys_i]]
                    new_blks[phys_i] = blk
                ne.compressed_blocks = new_blks
                ne.offset = new_blks[0].start if new_blks else len(out_buf)
                ne.size = sum(b.end - b.start for b in new_blks)

            stored_bytes = bytes(out_buf[ne.offset:ne.offset + ne.size])
            ne.content_hash = SHA1.new(stored_bytes).digest()

            new_files.append(ne)
            all_dirs.setdefault(dir_key, {})[p.name] = ne
            file_rows.append((fp, ne.uncompressed_size, ne.size))
            progress.update(task, advance=1, description=f"{p.name}")

    summary = Table(title=f"Files Added to New PAK  · {CREDIT}", box=ROUNDED, border_style="white")
    summary.add_column("Path in PAK", style="white")
    summary.add_column("Original Size", justify="right", style="dim")
    summary.add_column("Stored Size", justify="right", style="dim")
    for fp, orig_sz, stored_sz in file_rows:
        summary.add_row(fp, human_size(orig_sz), human_size(stored_sz))
    console.print(summary)

    id_to_idx = {id(ne): i for i, ne in enumerate(new_files)}

    idx = bytearray(_pw_string(mp_str))
    idx += struct.pack('<I', len(new_files))
    for ne in new_files:
        idx += _pw_entry(ne, version)
    idx += struct.pack('<Q', len(all_dirs))
    for dp_str, dir_files in all_dirs.items():
        idx += _pw_string(dp_str)
        idx += struct.pack('<Q', len(dir_files))
        for name, e in dir_files.items():
            idx += _pw_string(name)
            idx += struct.pack('<i', ~id_to_idx[id(e)])

    index_plain = bytes(idx)
    new_sha1 = SHA1.new(index_plain).digest()

    if pak_file._pak_info.index_encrypted:
        try:
            key = PakCrypto.rsa_extract(pak_file._pak_info.packed_key, RSA_MOD_1)
            iv = PakCrypto.rsa_extract(pak_file._pak_info.packed_iv, RSA_MOD_1)
            if key and iv and len(key) == 32 and len(iv) >= 16:
                aes = AES.new(key, MODE_CBC, iv[:16])
                pad = (-len(index_plain)) % AES.block_size or AES.block_size
                index_bytes = aes.encrypt(index_plain + bytes([pad] * pad))
            else:
                index_bytes = index_plain
        except:
            index_bytes = index_plain
    else:
        index_bytes = index_plain

    new_idx_offset = len(out_buf)
    new_idx_size = len(index_bytes)
    out_buf += index_bytes

    orig_fc = pak_file._file_content
    footer_sz = TencentPakInfo._mem_size(version)
    new_footer = bytearray(orig_fc[-footer_sz:])

    h_key = struct.pack('<5I', *keystream[4:9])
    new_footer[-36:-16] = bytes(a ^ b for a, b in zip(new_sha1, h_key))
    new_footer[-16:-8] = ((new_idx_size ^ (keystream[10] << 32 | keystream[11])).to_bytes(8, 'little'))
    new_footer[-8:] = ((new_idx_offset ^ (keystream[0] << 32 | keystream[1])).to_bytes(8, 'little'))
    out_buf += new_footer

    with open(output_path, 'wb') as f:
        f.write(out_buf)

    console.print(f'[green]New PAK written: {output_path}  [dim]· {CREDIT}[/dim][/]')
    console.print(f'[green]Files included: {len(new_files)}  [dim]· {CREDIT}[/dim][/]')

    try:
        check_pak = TencentPakFile(output_path, is_od=True)
    except AssertionError:
        console.print(f'[red]VERIFICATION FAILED (index hash mismatch)  [dim]({CREDIT})[/dim][/]')
    except Exception as e:
        console.print(f'[red]VERIFICATION FAILED: {e}  [dim]({CREDIT})[/dim][/]')

    return len(new_files)

# ==============================================================================
# PAK TOOL FUNCTIONS  |  CREDIT: @L4DXOP
# ==============================================================================

def display_file_selector(title, folder_path, file_pattern="*.pak"):
    files = list(folder_path.glob(file_pattern))
    if not files:
        hexa_alert(f"No {file_pattern} files found in {folder_path}", "error")
        return None, None

    table = Table(box=ROUNDED, show_header=True, expand=True, padding=(0, 1), border_style=ACCENT)
    table.add_column("#", justify="right", style=f"bold {GOLD}", width=4)
    table.add_column("File", style=f"bold {NEON}")
    table.add_column("Size", justify="right", style=MUTED)

    for i, f in enumerate(files, 1):
        size_mb = f.stat().st_size / (1024 * 1024)
        table.add_row(f"[{i}]", f.name, f"{size_mb:.2f} MB")

    console.print()
    console.print(Panel(table, title=f"[bold {ACCENT}] {title}  · {CREDIT} [/bold {ACCENT}]",
                        border_style=GOLD, box=HEAVY, padding=(1, 2)))

    try:
        idx = int(hexa_prompt(f"Select file (1-{len(files)})")) - 1
        if idx < 0 or idx >= len(files):
            hexa_alert("Invalid selection", "error")
            return None, None
        return files[idx], files
    except ValueError:
        hexa_alert("Please enter a valid number", "error")
        return None, None

# ==============================================================================
# PAK TOOL ACTIONS  |  CREDIT: @L4DXOP
# ==============================================================================

def action_unpack_pak():
    pak_dir = PAK_DIR
    if not pak_dir.exists():
        hexa_alert(f"PAK folder not found at {pak_dir}", "error")
        safe_input('\nPress Enter...')
        return

    pak_file, _ = display_file_selector("Available .pak files to UNPACK", pak_dir)
    if not pak_file:
        safe_input('\nPress Enter...')
        return

    try:
        hexa_section(f"Unpacking {pak_file.name}")
        pak = TencentPakFile(pak_file)
        unpack_path = PAK_UNPACK_DIR / pak_file.stem
        pak.dump(unpack_path)
        hexa_alert(f"Extracted to {unpack_path}  [dim]· {CREDIT}[/dim]", "success")
    except Exception as e:
        hexa_alert(f"{escape(str(e))}", "error")
    safe_input('\nPress Enter to continue...')

# ==============================================================================
# UTILITY ACTIONS - CLEAN & CLOSE  |  CREDIT: @L4DXOP
# ==============================================================================

def action_clean_all():
    try:
        L4DXOP_dir = Path("/storage/emulated/0/Documents/L4DXOP_LUA_TOOL/L4DXOP")

        if L4DXOP_dir.exists():
            console.print(f"[bold yellow]⚠ Found L4DXOP directory, removing...  [dim]· {CREDIT}[/dim][/bold yellow]")
            shutil.rmtree(L4DXOP_dir)
            console.print(f"[bold green]✅ L4DXOP directory removed successfully!  [dim]· {CREDIT}[/dim][/bold green]")
        else:
            console.print(f"[dim]No L4DXOP directory found.  · {CREDIT}[/dim]")

        temp_files = list(Path("/storage/emulated/0/Documents/L4DXOP_LUA_TOOL").glob("*.temp.std.luac"))
        if temp_files:
            for f in temp_files:
                try:
                    f.unlink()
                except:
                    pass
            console.print(f"[green]✅ Removed {len(temp_files)} temporary files.  · {CREDIT}[/green]")

        cache_dirs = list(Path("/storage/emulated/0/Documents/L4DXOP_LUA_TOOL").glob("__pycache__"))
        for cache_dir in cache_dirs:
            try:
                shutil.rmtree(cache_dir)
                console.print(f"[green]✅ Removed {cache_dir}  · {CREDIT}[/green]")
            except:
                pass

        console.print(f"[bold green]✨ Cleanup complete!  · {CREDIT}[/bold green]")
    except Exception as e:
        console.print(f"[red]❌ Error during cleanup: {e}  · {CREDIT}[/red]")

    safe_input('\nPress Enter to continue...')

def action_close_termux():
    try:
        console.print()
        ab = AnimatedBorder.get_instance()
        border_color = ab.get_moving_border_style(6, 0.7)
        console.print(Panel(
            f"[bold white]═══ {TOOL_NAME} ═══[/bold white]\n\n"
            "[bold white]Thank you for using![/bold white]\n\n"
            "[bold green]DEVELOPER[/bold green]  :   @L4DXOP\n"
            "[bold green]OWNER[/bold green]      :   L4DXOP\n"
            f"[bold green]CREDIT[/bold green]     :   {CREDIT}\n"
            f"[bold green]TOOL BY[/bold green]    :   {CREDIT}\n",
            border_style=border_color, box=HEAVY, padding=(1, 2)))
        time.sleep(1.5)

        if sys.platform != 'win32':
            sys.stdout.flush()
            sys.stderr.flush()
            os.system('pkill -9 -f com.termux 2>/dev/null')
            os._exit(0)
        else:
            sys.exit(0)
    except Exception as e:
        console.print(f"[yellow]Force closing...  [dim]· {CREDIT}[/dim][/yellow]")
        try:
            os.system('pkill -9 -f com.termux 2>/dev/null')
        except:
            pass
        os._exit(0)

def action_repack_inject():
    pak_dir = PAK_DIR
    edit_dir = EDIT_DIR
    result_dir = RESULT_DIR

    if not pak_dir.exists():
        hexa_alert(f"PAK folder not found at {pak_dir}", "error")
        safe_input('\nPress Enter...')
        return

    pak_file, _ = display_file_selector("Available .pak files to REPACK TO PATH", pak_dir)
    if not pak_file:
        safe_input('\nPress Enter...')
        return

    if not edit_dir.exists() or not any(edit_dir.iterdir()):
        hexa_alert("No files in COMPILED folder. Place files to add in COMPILED first.", "error")
        safe_input('\nPress Enter...')
        return

    console.print()
    console.print(Panel(f"Target path inside the PAK where files should be added.\n[{MUTED}]e.g. Content/Lua/GameLua/Mod/BRMod/Gameplay/Core[/{MUTED}]\n[dim]Credit: {CREDIT}[/dim]",
                        border_style=ACCENT, box=ROUNDED, padding=(0, 2)))

    console.print("[dim]Press Enter to use default: Content/Lua/[/dim]")

    target_path = safe_input(f"\n[bold yellow]Path [{CREDIT}]: [/bold yellow]").strip()

    if not target_path:
        target_path = "Content/Lua/"
        console.print(f"[dim]Using default path: {target_path}[/dim]")
    else:
        console.print(f"[dim]Using custom path: {target_path}[/dim]")

    target_path = target_path.replace('\\', '/').strip('/')
    if not target_path:
        hexa_alert("Invalid target path", "error")
        safe_input('\nPress Enter...')
        return

    try:
        hexa_section(f"Adding files to {target_path} · {pak_file.name}")
        pak = TencentPakFile(pak_file)
        output_pak = result_dir / pak_file.name

        console.print(f"[bold green]▶ Auto-proceeding with repack...  [dim]· {CREDIT}[/dim][/bold green]")

        count = repack_pak_file_full(pak, edit_dir, output_pak, target_path, force_add=True)
        if count > 0:
            hexa_alert(f"Processed {count} files to {target_path} -> {output_pak}\nPAK is game ready  [dim]· {CREDIT}[/dim]", "success")
        else:
            hexa_alert("No files were processed", "error")
    except Exception as e:
        hexa_alert(f"Repack failed: {e}", "error")
        traceback.print_exc()
    safe_input('\nPress Enter to continue...')

def action_build_new_pak():
    pak_dir = PAK_DIR
    edit_dir = EDIT_DIR
    result_dir = RESULT_DIR

    if not pak_dir.exists():
        hexa_alert(f"PAK folder not found at {pak_dir}", "error")
        safe_input('\nPress Enter...')
        return

    pak_file, _ = display_file_selector("Select TEMPLATE PAK", pak_dir)
    if not pak_file:
        safe_input('\nPress Enter...')
        return

    if not edit_dir.exists() or not any(edit_dir.iterdir()):
        hexa_alert("No files in COMPILED folder. Place files to add in COMPILED first.", "error")
        safe_input('\nPress Enter...')
        return

    console.print()
    console.print(Panel(
        f"Target path inside PAK (or blank for relative).\n"
        f"Files will be added to this path inside the new PAK.\n"
        f"[dim]e.g. Content/Lua/GameLua/Mod/BRMod/Gameplay/Core[/dim]\n"
        f"[dim]Press Enter directly for no path (files at root)[/dim]\n"
        f"[dim]Credit: {CREDIT}[/dim]",
        border_style=ACCENT, box=ROUNDED, padding=(0, 2)
    ))

    target_path = safe_input(f"\n[bold yellow]Target path (press Enter for no path) [{CREDIT}]: [/bold yellow]").strip()

    if target_path:
        target_path = target_path.replace('\\', '/').strip('/')
        console.print(f"[dim]Using custom path: {target_path}[/dim]")
    else:
        target_path = ""
        console.print("[dim]No path set - files will be at root[/dim]")

    output_pak = result_dir / pak_file.name

    try:
        hexa_section(f"Building NEW PAK using template: {pak_file.name}")
        console.print(f"[bold green]▶ Auto-proceeding with build...  [dim]· {CREDIT}[/dim][/bold green]")
        count = build_new_pak_from_template(pak_file, edit_dir, output_pak, target_path)
        if count > 0:
            hexa_alert(f"New PAK built with {count} files!  [dim]· {CREDIT}[/dim]", "success")
            hexa_alert(f"Output: {output_pak}", "info")
        else:
            hexa_alert("Build failed - no files processed", "error")
    except Exception as e:
        hexa_alert(f"Build failed: {e}", "error")
        traceback.print_exc()
    safe_input('\nPress Enter to continue...')

def action_inject_lua():
    console.print(f"\n[bold #00AAFF]📦 INJECT LUA - REPACK TO PAK  [dim]({CREDIT})[/dim][/bold #00AAFF]")
    console.print(f"[white]Inject Lua files directly into PAK  [dim]· {CREDIT}[/dim][/white]")
    console.print()

    edit_dir = EDIT_DIR
    out_path = RESULT_DIR
    pak_dir = PAK_DIR

    if not edit_dir.exists():
        edit_dir.mkdir(parents=True, exist_ok=True)
        console.print(f"[yellow]⚠ Created empty folder: {edit_dir}  [dim]· {CREDIT}[/dim][/yellow]")
        console.print(f"[yellow]Please add your LUA files there first!  [dim]· {CREDIT}[/dim][/yellow]")
        safe_input("\nPress Enter to continue...")
        return

    files_in_edit = [f for f in edit_dir.rglob("*") if f.is_file() and f.name not in ['pak_manifest.json','.DS_Store']]
    if not files_in_edit:
        console.print(f"[bold red]❌ COMPILED folder is empty!  [dim]({CREDIT})[/dim][/bold red]")
        console.print(f"[red]📁 Please put LUA files in: {edit_dir}  [dim]· {CREDIT}[/dim][/red]")
        safe_input("\nPress Enter to continue...")
        return

    console.print(f"\n[bold cyan]📂 Files found in COMPILED folder:  [dim]({CREDIT})[/dim][/bold cyan]")
    files = []
    for idx, f in enumerate(files_in_edit, 1):
        rel_path = str(f.relative_to(edit_dir)).replace("\\", "/")
        files.append((f, rel_path))
        if len(rel_path) > 60:
            display_path = "..." + rel_path[-57:]
        else:
            display_path = rel_path
        console.print(f"  [{idx}] {display_path}")

    console.print(f"\n[bold green]Enter the target path inside the PAK:  [dim]({CREDIT})[/dim][/bold green]")
    console.print("[dim]Example: Content/Lua/GameLua/Mod/BRMod/Gameplay/Core/[/dim]")
    console.print("[dim]Press Enter to use default: filename only[/dim]")

    base_path = safe_input(f"\n[bold yellow]Path [{CREDIT}]: [/bold yellow]").strip()

    if not base_path:
        base_path = ""
        console.print("[dim]No base path - files will be at root[/dim]")
    else:
        if not base_path.endswith('/'):
            base_path += '/'
        console.print(f"[dim]Using custom path: {base_path}[/dim]")

    file_locations = {}
    for f, rel_path in files:
        if base_path:
            file_locations[str(f)] = base_path + f.name
        else:
            file_locations[str(f)] = f.name

    console.print(f"\n[green]✅ {len(files)} files will be injected  [dim]· {CREDIT}[/dim][/green]")

    for f, loc in list(file_locations.items())[:5]:
        short_name = Path(f).name[:30] + "..." if len(Path(f).name) > 30 else Path(f).name
        console.print(f"  [dim]•[/dim] {short_name} → [yellow]{loc}[/yellow]")
    if len(file_locations) > 5:
        console.print(f"  [dim]... and {len(file_locations) - 5} more files  · {CREDIT}[/dim]")

    console.print(f"\n[bold green]▶ Auto-proceeding with injection...  [dim]· {CREDIT}[/dim][/bold green]")

    console.print(f"[cyan]🔍 Searching for PAK files in PAK_ORIGINAL...  [dim]({CREDIT})[/dim][/cyan]")
    pak_files = []
    for file in pak_dir.iterdir():
        if file.name.lower().endswith('.pak'):
            pak_files.append(file)

    if not pak_files:
        console.print(f"[bold red]❌ No PAK file found in PAK_ORIGINAL folder!  [dim]({CREDIT})[/dim][/bold red]")
        console.print(f"[red]📁 Please put PAK file in: {pak_dir}  [dim]· {CREDIT}[/dim][/red]")
        safe_input("\nPress Enter to continue...")
        return

    if len(pak_files) == 1:
        pak_path = pak_files[0]
        console.print(f"[green]✅ Found PAK: {pak_path.name}  [dim]· {CREDIT}[/dim][/green]")
    else:
        console.print(f"[yellow]⚠️ Multiple PAK files found:  [dim]({CREDIT})[/dim][/yellow]")
        for i, pak in enumerate(pak_files, 1):
            console.print(f"  [{i}] {pak.name}")
        console.print(f"\n[bold yellow]Enter number to select [{CREDIT}]:[/bold yellow]")
        try:
            choice_pak = int(safe_input("> ").strip())
            if 1 <= choice_pak <= len(pak_files):
                pak_path = pak_files[choice_pak - 1]
                console.print(f"[green]✅ Selected: {pak_path.name}  · {CREDIT}[/green]")
            else:
                console.print(f"[bold red]❌ Invalid choice!  [dim]({CREDIT})[/dim][/bold red]")
                safe_input("\nPress Enter to continue...")
                return
        except:
            console.print(f"[bold red]❌ Invalid input!  [dim]({CREDIT})[/dim][/bold red]")
            safe_input("\nPress Enter to continue...")
            return

    BACKUP_FOLDER = PAK_DIR.parent / "BACKUP"
    BACKUP_FOLDER.mkdir(exist_ok=True)
    backup_name = f"{pak_path.stem}_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pak"
    backup_path = BACKUP_FOLDER / backup_name
    shutil.copy2(pak_path, backup_path)
    console.print(f"[bold green]✅ Backup created: {backup_path}  · {CREDIT}[/bold green]")

    try:
        console.print(f"[cyan]📦 Loading PAK file...  [dim]({CREDIT})[/dim][/cyan]")
        pak = TencentPakFile(PurePath(pak_path))
        output_name = f"{pak_path.stem}_MODIFIED.pak"
        output_pak = out_path / output_name

        console.print(f"[cyan]🔄 Repacking PAK...  [dim]({CREDIT})[/dim][/cyan]")

        dominant = pak.detect_dominant_style()
        console.print(f"[cyan]Dominant style: comp={dominant['comp_method']}, enc={dominant['enc_method']}, encrypted={dominant['encrypted']}, block={dominant['block_size']}  · {CREDIT}[/cyan]")

        inject_plan = []
        for f, rel_path in files:
            internal_path = file_locations.get(str(f), f.name)

            if internal_path.startswith('/'):
                internal_path = internal_path[1:]

            inject_plan.append({
                'src_path': f,
                'internal_path': internal_path,
                'comp_method': dominant['comp_method'],
                'enc_method': dominant['enc_method'],
                'encrypted': dominant['encrypted'],
                'block_size': dominant['block_size'],
            })

        console.print(f"[green]Plan: {len(inject_plan)} files with custom locations.  · {CREDIT}[/green]")

        pak.inject_files(inject_plan, Path(output_pak))
        console.print(f"[bold green]✅ Repack complete! Output: {output_pak}  · {CREDIT}[/bold green]")
        console.print(f"[green]Processed {len(inject_plan)} files with custom locations.  · {CREDIT}[/green]")

    except Exception as e:
        console.print(f"[bold red]❌ Error: {e}  [dim]({CREDIT})[/dim][/bold red]")
        import traceback
        traceback.print_exc()

    safe_input("\nPress Enter to continue...")

# ==============================================================================
# MAIN MENU  |  CREDIT: @L4DXOP
# ==============================================================================

def main_menu():
    try:
        if DECOMP_LOG_FILE.exists():
            DECOMP_LOG_FILE.unlink()
    except Exception:
        pass
        
    setup_directories()
    ab = AnimatedBorder.get_instance()

    while True:
        print_main_banner(key_info=None)

        menu_table = Table(box=ROUNDED, show_header=False, padding=(0, 2), border_style=RED)
        menu_table.add_column(justify="right", style=f"bold {GREEN}", width=4)
        menu_table.add_column(justify="left", style=f"bold {NEON}", min_width=18)
        menu_table.add_column(justify="left", style=MUTED)

        menu_table.add_row("1.", "UNPACK_PAK", f"extract every entry from a .pak  · {CREDIT}")
        menu_table.add_row("2.", "LUA_MAKE", f"Decompile & Recompile .luac  · {CREDIT}")
        menu_table.add_row("3.", "REPACK_LUA_PAK", f"add new files a target path  · {CREDIT}")
        menu_table.add_row("4.", "BUILD_NEW_PAK", f"build new PAK from template  · {CREDIT}")
        menu_table.add_row("5.", "INJECT_LUA", f"Inject Lua Without Firewall  · {CREDIT}")
        menu_table.add_row("6.", "CLEAN_ALL", f"remove a L4DXOP directory  · {CREDIT}")
        menu_table.add_row("7.", "CLOSE_TERMUX", f"close the tool  · {CREDIT}")

        border_color = ab.get_moving_border_style(2, 0.5)
        console.print(Panel(menu_table, title=f"[bold white]═══ MAIN MENU ═══  ·  {CREDIT}[/bold white]",
                            border_style=border_color, box=HEAVY, padding=(1, 2)))
        print_credit()
        console.print()

        choice = hexa_prompt("Enter your choice")

        if choice == '1':
            action_unpack_pak()
        elif choice == '2':
            lua_mode_menu()
        elif choice == '3':
            action_repack_inject()
        elif choice == '4':
            action_build_new_pak()
        elif choice == '5':
            action_inject_lua()
        elif choice == '6':
            action_clean_all()
        elif choice == '7':
            action_close_termux()
            break
        else:
            hexa_alert("Invalid choice", "error")
            time.sleep(2)

def lua_mode_menu():
    ab = AnimatedBorder.get_instance()

    while True:
        print_main_banner("LUA_MAKE")

        menu_table = Table(box=ROUNDED, show_header=False, padding=(0, 2), border_style=RED)
        menu_table.add_column(justify="right", style=f"bold {GREEN}", width=4)
        menu_table.add_column(justify="left", style=f"bold {NEON}", min_width=18)
        menu_table.add_column(justify="left", style=MUTED)

        menu_table.add_row("1.", "RECOMPILE", f"LUA_EDIT COMPILED  · {CREDIT}")
        menu_table.add_row("2.", "DECOMPILE", f"LUA_ORIGINAL  · {CREDIT}")
        menu_table.add_row("3.", "BACK", f"return to main menu  · {CREDIT}")

        border_color = ab.get_moving_border_style(4, 0.5)
        console.print(Panel(menu_table, title=f"[bold white]═══ LUA_MAKE ═══  ·  {CREDIT}[/bold white]",
                            border_style=border_color, box=HEAVY, padding=(1, 2)))
        print_credit()
        console.print()

        choice = hexa_prompt("Select option: ").strip()
        if choice == '1':
            action_repack_unpack()
        elif choice == '2':
            action_unpack()
        elif choice == '3':
            return
        else:
            hexa_alert("Invalid option", "error")
            time.sleep(1)

if __name__ == "__main__":
    # ─── Banner splash with credit ───
    console.print()
    console.print(f"[bold {GOLD}]╔══════════════════════════════════════════════════════════╗[/bold {GOLD}]")
    console.print(f"[bold {GOLD}]║[/bold {GOLD}]      [bold {NEON}]⚡ {TOOL_NAME} ⚡[/bold {NEON}]      [bold {GOLD}]║[/bold {GOLD}]")
    console.print(f"[bold {GOLD}]║[/bold {GOLD}]         [bold {GREEN}]DEVELOPER : @L4DXOP[/bold {GREEN}]                [bold {GOLD}]║[/bold {GOLD}]")
    console.print(f"[bold {GOLD}]║[/bold {GOLD}]         [bold {GREEN}]OWNER     : L4DXOP[/bold {GREEN}]                      [bold {GOLD}]║[/bold {GOLD}]")
    console.print(f"[bold {GOLD}]║[/bold {GOLD}]         [bold {GOLD}]CREDIT    : {CREDIT}[/bold {GOLD}]            [bold {GOLD}]║[/bold {GOLD}]")
    console.print(f"[bold {GOLD}]║[/bold {GOLD}]         [bold {MAGENTA}]TOOL BY   : {CREDIT}[/bold {MAGENTA}]            [bold {GOLD}]║[/bold {GOLD}]")
    console.print(f"[bold {GOLD}]╚══════════════════════════════════════════════════════════╝[/bold {GOLD}]")
    console.print()
    console.print(f"  [bold {NEON}]✨ No login required — Straight to the tool! ✨[/bold {NEON}]")
    console.print(f"  [bold {GOLD}]💎 Powered & Credited by {CREDIT} 💎[/bold {GOLD}]")
    console.print()
    time.sleep(1.5)

    try:
        main_menu()
    except KeyboardInterrupt:
        console.print(f"\n[bold {WARN}]Interrupted. Exiting...  [dim]({CREDIT})[/dim][/bold {WARN}]")
        sys.exit(0)
    except Exception as e:
        console.print(f"[bold {ERR}]FATAL: {escape(str(e))}  [dim]({CREDIT})[/dim][/bold {ERR}]")
        traceback.print_exc()
        safe_input('\nPress Enter to exit...')
        sys.exit(1)

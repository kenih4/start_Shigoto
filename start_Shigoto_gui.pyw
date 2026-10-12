"""start_Shigoto.bat のGUI版。項目ごとに 有効/無効・状態表示・個別実行 ができる。"""
import ctypes
import json
import os
import subprocess
import sys
import tempfile
import threading
import time
import tkinter as tk
from tkinter import messagebox
from datetime import datetime
from tkinter import ttk

BASE = os.path.dirname(os.path.abspath(__file__))
SETTINGS = os.path.join(BASE, "start_Shigoto_gui.json")

PY = r"C:\Users\kenic\AppData\Local\Programs\Python\Python313\python.exe"
PS = 'powershell -ExecutionPolicy Bypass -NoProfile -File'
GIT = r"C:\Users\kenic\Dropbox\gitdir"
LOGNOTE = rf"python {GIT}\CopyAndOpenExcel\download_LOGNOTE_GUI.py"

# pause_after=True : 一括実行時、この項目の後で「次へ進む」ボタンを押すまで待つ
# wait=True : 終了するまで待ってから次へ / False : 起動したら次へ進む(常駐アプリなど)
ITEMS = [
    dict(id="hikitsugi", name="VS Code: hikitsugi を開く", wait=False,
         cmd=rf"code {GIT}\hikitsugi"),
    dict(id="teams", name="Teams を開く", wait=True, pause_after=True,
         cmd=rf'{PS} "{BASE}\Open_teams.ps1"'),
    dict(id="ln_sp8", name="ログノート取得 SP8", wait=True,
         cmd=f"{LOGNOTE} SP8 {{yyyy}} {{mm}} true"),
    dict(id="ln_sacla", name="ログノート取得 SACLA", wait=True,
         cmd=f"{LOGNOTE} SACLA {{yyyy}} {{mm}} true"),
    dict(id="ln_scss", name="ログノート取得 SCSS", wait=True, pause_after=True,
         cmd=f"{LOGNOTE} SCSS {{yyyy}} {{mm}} true"),
    dict(id="open_web", name="open_web.ps1 (Webページを開く)", wait=True,
         cmd=rf'{PS} "{GIT}\open_web\open_web.ps1"', cwd=rf"{GIT}\open_web"),
    dict(id="server_login", name="サーバー接続 (server_login.bat)", wait=False, keep_open=True,
         cmd=rf"{GIT}\Startup\server_login.bat"),
    dict(id="screen", name="画面オフ時間を1分にする", wait=True,
         cmd=rf'{PS} "{BASE}\SetScreenTimeout.ps1"'),
    dict(id="hotspot", name="Wi-Fiホットスポット ON", wait=True,
         cmd=rf'{PS} "{GIT}\setup-ntfy\hotspot-wifi.ps1"'),
    dict(id="oto", name="Oto Monitor GUI 起動", wait=False,
         cmd=rf"python {GIT}\Oto_New\oto_monitor_gui.pyw"),
    dict(id="mail", name="Activeメール受信スクリプト起動", wait=False,
         cmd=rf"{PY} {GIT}\check_latest_mail_IMAP4\check_latest_mail_IMAP4.py kenichi ribsgroup"),
    dict(id="copy_shift", name="2026年度シフト表.xlsm を Dropbox にコピー", wait=True,
         keep_open=True, enter_close=True,
         cmd=r"copy \\saclaopr18.spring8.or.jp\common\シフト\2026年度\2026年度シフト表.xlsm C:\Users\kenic\Dropbox"),
    dict(id="bu_unten", name="運転集計のバックアップ (xcopy)", wait=True,
         keep_open=True, enter_close=True,
         cmd=r"xcopy /E /I \\saclaopr18.spring8.or.jp\common\運転状況集計\最新\SACLA "
             r"D:\BU\運転集計のバックアップ\最新\SACLA_{yyyy}_{mm}_{dd}"),
]

BG, FG, BG2, ACC = "#1e1e1e", "#d4d4d4", "#2d2d30", "#3c3c3f"
LINE = "#44444a"      # グリッド線
COLORS = {"待機": "#9a9a9a", "実行中": "#f0a030", "完了": "#4ec36b",
          "失敗": "#f05050", "無効": "#5a5a5a", "停止": "#f05050"}


class App:
    def __init__(self, root):
        self.root = root
        root.title("Start Shigoto")
        root.geometry("640x640")
        self._dark_theme()
        self._set_icon()
        self.procs = {}          # id -> Popen
        self.status = {}         # id -> str
        self.enabled = {}        # id -> BooleanVar
        self.status_lbl = {}
        self.name_chk = {}
        self.abort = False
        self.running_all = False
        self.markers = {}        # id -> 終了コードを書き出すファイル(keep_open項目)
        self.proceed = threading.Event()
        self.waiting = False
        self.blinking = False     # 「次へ進む」ボタンの点滅(Noを選ぶと止める)

        saved = self._load()
        # 設定ファイルの "keep_open" で項目ごとに、ターミナルを残すか(true)/終了後に閉じるか(false)を指定
        self._apply_keep_open(saved)
        top = ttk.Frame(root, padding=8)
        top.pack(fill="x")
        self.btn_all = ttk.Button(top, text="▶ 有効な項目をすべて実行", command=self.run_all)
        self.btn_all.pack(side="left")
        self.btn_next = ttk.Button(top, text="⏭ 次へ進む", command=self.proceed.set,
                                   state="disabled", style="Next.TButton")
        self.btn_next.pack(side="left", padx=4)
        ttk.Button(top, text="中止", command=self.abort_all).pack(side="left", padx=4)
        ttk.Button(top, text="全選択", command=lambda: self.set_all(True)).pack(side="left", padx=(16, 0))
        ttk.Button(top, text="全解除", command=lambda: self.set_all(False)).pack(side="left", padx=4)
        ttk.Button(top, text="設定ファイル", command=self.open_settings).pack(side="right")
        self.stop_on_fail = tk.BooleanVar(value=saved.get("stop_on_fail", False))
        ttk.Checkbutton(top, text="失敗で止める", variable=self.stop_on_fail,
                        command=self._save).pack(side="left", padx=12)

        body = ttk.Frame(root, padding=(8, 0))
        body.pack(fill="x")
        for i, it in enumerate(ITEMS):
            v = tk.BooleanVar(value=saved.get("enabled", {}).get(it["id"], True))
            v.trace_add("write", lambda *_: self._on_toggle())
            self.enabled[it["id"]] = v
            self.status[it["id"]] = "待機"
            r = i * 2
            chk = ttk.Checkbutton(body, text=f'{i + 1}. {it["name"]}', variable=v)
            chk.grid(row=r, column=0, sticky="w", pady=4)
            tk.Frame(body, width=1, bg=LINE).grid(row=r, column=1, sticky="ns")
            lbl = tk.Label(body, text="待機", width=9, bg=BG, anchor="w",
                           font=("Meiryo UI", 10, "bold"))
            lbl.grid(row=r, column=2, padx=8)
            tk.Frame(body, width=1, bg=LINE).grid(row=r, column=3, sticky="ns")
            ttk.Button(body, text="▶", width=3,
                       command=lambda it=it: self.run_one(it)).grid(row=r, column=4, padx=(8, 2))
            ttk.Button(body, text="■", width=3,
                       command=lambda it=it: self.stop_one(it["id"])).grid(row=r, column=5, padx=(0, 4))
            tk.Frame(body, height=1, bg=LINE).grid(row=r + 1, column=0, columnspan=6, sticky="ew")
            self.status_lbl[it["id"]] = lbl
            self.name_chk[it["id"]] = chk
        body.columnconfigure(0, weight=1)

        self.log = tk.Text(root, height=10, state="disabled", font=("Consolas", 9),
                        bg=BG2, fg=FG, insertbackground=FG, relief="flat")
        self.log.pack(fill="both", expand=True, padx=8, pady=8)

        self._save()        # 初回起動時も設定ファイルを作る
        self._refresh()
        root.protocol("WM_DELETE_WINDOW", root.destroy)

    def open_settings(self):
        code = r"C:\Users\kenic\AppData\Local\Programs\Microsoft VS Code\Code.exe"
        subprocess.Popen([code, r"C:\Users\kenic\Dropbox\gitdir\start_Shigoto"],
                         creationflags=subprocess.CREATE_NO_WINDOW)

    def _set_icon(self):
        """タスクバーのアイコン。start_Shigoto.ico があればそれを使い、無ければ描画した既定アイコン"""
        try:       # python.exe とは別アプリとして扱わせる(アイコンのグループ化を避ける)
            ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID("kenih4.start_Shigoto")
        except Exception:
            pass
        ico = os.path.join(BASE, "start_Shigoto.ico")
        try:
            if os.path.exists(ico):
                self.root.iconbitmap(default=ico)
                return
            n = 64
            img = tk.PhotoImage(width=n, height=n)
            img.put("#0e7ad1", to=(0, 0, n, n))
            img.put("#1e1e1e", to=(6, 6, n - 6, n - 6))
            for y in range(16, 49):          # ▶ の三角形
                w = int((16 - abs(y - 32)) * 1.7)
                if w > 0:
                    img.put("#4ec36b", to=(22, y, 22 + w, y + 1))
            self._icon = img                 # 参照を保持
            self.root.iconphoto(True, img)
        except Exception:
            pass

    def _dark_theme(self):
        self.root.configure(bg=BG)
        st = ttk.Style()
        st.theme_use("clam")
        st.configure(".", background=BG, foreground=FG, fieldbackground=BG2)
        st.configure("TFrame", background=BG)
        st.configure("TButton", background=ACC, foreground=FG, borderwidth=0, padding=4)
        st.map("TButton", background=[("active", "#505055"), ("disabled", BG2)],
               foreground=[("disabled", "#777777")])
        st.configure("Next.TButton", background=ACC, foreground=FG, borderwidth=0, padding=4)
        st.configure("NextOn.TButton", background="#f0a030", foreground="#000000",
                     borderwidth=0, padding=4)
        st.map("NextOn.TButton", background=[("active", "#ffc060")])
        st.configure("TCheckbutton", background=BG, foreground=FG)
        st.map("TCheckbutton", background=[("active", BG)])
        # clam の既定は ☒ なので、チェック印のインジケータ画像を自前で描く
        n = 18
        off, on = tk.PhotoImage(width=n, height=n), tk.PhotoImage(width=n, height=n)
        for img, fill in ((off, BG2), (on, "#0e7ad1")):
            img.put(BG, to=(0, 0, n, n))
            img.put("#7a7a80", to=(1, 1, n - 1, n - 1))
            img.put(fill, to=(2, 2, n - 2, n - 2))
        for x, y in ((4, 9), (5, 10), (6, 11), (7, 12), (8, 11), (9, 10), (10, 9),
                     (11, 8), (12, 7), (13, 6)):        # ✓ (太さ2px)
            for dy in (0, 1):
                on.put("#ffffff", to=(x, y - 2 + dy, x + 1, y - 1 + dy))
        self._check_imgs = (off, on)
        st.element_create("Dark.indicator", "image", off, ("selected", on))
        st.layout("TCheckbutton", [("Checkbutton.padding", {"sticky": "nswe", "children": [
            ("Dark.indicator", {"side": "left", "sticky": ""}),
            ("Checkbutton.focus", {"side": "left", "sticky": "w", "children": [
                ("Checkbutton.label", {"sticky": "nswe"})]})]})])

    # ---- 設定 -------------------------------------------------------------
    def _load(self):
        try:
            with open(SETTINGS, encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}

    def _save(self):
        data = {"enabled": {k: v.get() for k, v in self.enabled.items()},
                "keep_open": self.keep_open,
                "stop_on_fail": self.stop_on_fail.get()}
        try:
            with open(SETTINGS, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        except OSError:
            pass

    def _apply_keep_open(self, saved):
        ko = saved.get("keep_open", {})
        self.keep_open = {it["id"]: bool(ko.get(it["id"], it.get("keep_open", False)))
                          for it in ITEMS}

    def _on_toggle(self):
        self._save()
        self._refresh()

    def set_all(self, val):
        for v in self.enabled.values():
            v.set(val)

    # ---- ログ -------------------------------------------------------------
    def say(self, msg):
        def _do():
            self.log.configure(state="normal")
            self.log.insert("end", f"[{datetime.now():%H:%M:%S}] {msg}\n")
            self.log.see("end")
            self.log.configure(state="disabled")
        self.root.after(0, _do)

    # ---- 実行 -------------------------------------------------------------
    def _launch(self, it):
        now = datetime.now()
        cmd = it["cmd"].format(yyyy=f"{now:%Y}", mm=f"{now:%m}", dd=f"{now:%d}")
        self._apply_keep_open(self._load())      # 実行のたびに設定ファイルを読み直す
        term = self.keep_open.get(it["id"])
        if term:
            # cmd /k で終了後もウィンドウを残す。終了コードは目印ファイルで受け取る
            m = os.path.join(tempfile.gettempdir(), f'start_Shigoto_{it["id"]}.rc')
            if os.path.exists(m):
                os.remove(m)
            self.markers[it["id"]] = m
            run = f'({cmd}) && (>{m} echo 0) || (>{m} echo 1)'
            if it.get("enter_close"):
                # 終了後に Enter を入力するとターミナルが閉じる
                cmd = f'cmd /c "{run} & echo. & set /p _=Press Enter to close..."'
            else:
                cmd = f'cmd /k "{run}"'
        # shell=True だと cmd が SW_HIDE で起動されターミナルが見えないため、
        # ターミナルを出す項目は shell=False で cmd を直接起動する
        flags = subprocess.CREATE_NEW_CONSOLE if term else subprocess.CREATE_NO_WINDOW
        p = subprocess.Popen(cmd, shell=not term, cwd=it.get("cwd"), creationflags=flags)
        self.procs[it["id"]] = p
        self.status[it["id"]] = "実行中"
        self.say(f'開始: {it["name"]}')
        return p

    def _rc(self, iid):
        """終了コード。実行中(または未実行)なら None"""
        p = self.procs.get(iid)
        if p is None:
            return None
        m = self.markers.get(iid)
        if m:
            try:
                with open(m) as f:
                    return int(f.read().strip())
            except (OSError, ValueError):
                return p.returncode if p.poll() is not None else None
        return p.poll()

    def _finish(self, it, rc):
        if self.status[it["id"]] != "実行中":      # 二重通知の防止
            return
        self.status[it["id"]] = "完了" if rc == 0 else "失敗"
        self.say(f'{"完了" if rc == 0 else "失敗"}(code {rc}): {it["name"]}')

    def run_one(self, it):
        if self._is_running(it["id"]):
            return
        threading.Thread(target=self._run_item, args=(it, True), daemon=True).start()

    def _run_item(self, it, wait):
        """戻り値: 成功なら True"""
        try:
            p = self._launch(it)
        except Exception as e:
            self.status[it["id"]] = "失敗"
            self.say(f'起動エラー: {it["name"]}: {e}')
            return False
        if not (wait or it["wait"]):
            return True
        while self._rc(it["id"]) is None:
            if self.abort:
                return False
            time.sleep(0.3)
        rc = self._rc(it["id"])
        if self.procs.get(it["id"]) is p:       # 手動停止されていなければ
            self._finish(it, rc)
        return rc == 0

    def run_all(self):
        if self.running_all:
            return
        self.abort = False
        self.running_all = True
        for it in ITEMS:
            self.status[it["id"]] = "待機"
        threading.Thread(target=self._run_all_thread, daemon=True).start()

    def _run_all_thread(self):
        self.say("=== 一括実行 開始 ===")
        for it in ITEMS:
            if self.abort:
                break
            if not self.enabled[it["id"]].get():
                continue
            ok = self._run_item(it, False)
            if ok and it.get("pause_after") and not self.abort:
                self.say(f'「次へ進む」を押すと再開します (待機中: {it["name"]} の後)')
                self.proceed.clear()
                self.waiting = True
                self.blinking = True
                self.root.after(0, self._ask_proceed, it["name"])
                while not self.proceed.wait(0.3) and not self.abort:
                    pass
                self.waiting = False
                if self.abort:
                    break
            if not ok and self.stop_on_fail.get() and not self.abort:
                self.say("失敗したため中断しました")
                break
        self.say("=== 一括実行 終了 ===" if not self.abort else "=== 中止しました ===")
        self.running_all = False

    def _ask_proceed(self, name):
        """Yes/No で確認。Yes(既定。Enterのみで可)なら次へ進む。No なら待機を続ける"""
        if not self.waiting:
            return
        self.root.deiconify()
        self.root.lift()
        self.root.focus_force()
        msg = f"「{name}」が終了しました。" + chr(10) + "次へ進みますか?"
        if messagebox.askyesno("次へ進みますか?", msg, default="yes", parent=self.root):
            self.proceed.set()
        else:
            self.blinking = False
            self.say("待機を続けます(「次へ進む」ボタンで再開)")

    def abort_all(self):
        self.abort = True

    def stop_one(self, iid):
        p = self.procs.pop(iid, None)
        if p and p.poll() is None:
            subprocess.run(["taskkill", "/F", "/T", "/PID", str(p.pid)],
                           capture_output=True, creationflags=subprocess.CREATE_NO_WINDOW)
            self.status[iid] = "停止"
            self.say(f"停止: {iid}")

    def _is_running(self, iid):
        p = self.procs.get(iid)
        return p is not None and self._rc(iid) is None

    # ---- 表示更新 ---------------------------------------------------------
    def _refresh(self):
        for it in ITEMS:
            iid = it["id"]
            p = self.procs.get(iid)
            if p is not None and self.status[iid] == "実行中" and self._rc(iid) is not None:
                self._finish(it, self._rc(iid))      # 待たない項目の終了検知
            st = self.status[iid]
            if st == "待機" and not self.enabled[iid].get():
                st = "無効"
            lbl = self.status_lbl[iid]
            lbl.configure(text=("● " if st == "実行中" else "") + st,
                          fg=COLORS.get(st, "#000000"))
        self.btn_next.configure(state="normal" if self.waiting else "disabled")
        self._blink = not getattr(self, "_blink", False)
        # 待機中は 0.5秒ごとにオレンジ/通常色を切り替えて点滅させる
        self.btn_next.configure(style="NextOn.TButton" if self.waiting and self.blinking and self._blink
                                else "Next.TButton")
        self.btn_all.configure(state="disabled" if self.running_all else "normal")
        self.root.after(500, self._refresh)


if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    if "--start" in sys.argv[1:]:
        root.after(500, app.run_all)    # 「有効な項目をすべて実行」ボタン相当
    root.mainloop()

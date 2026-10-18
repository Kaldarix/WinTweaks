import sys
import os
import ctypes
from pathlib import Path

# Automatically install CustomTkinter if it's missing on the user's machine
try:
    import customtkinter as ctk
except ImportError:
    print("[INFO] CustomTkinter not found. Installing package...")
    os.system(f"{sys.executable} -m pip install customtkinter")
    import customtkinter as ctk

# Establish base paths and app version
BASE_DIR = Path(__file__).resolve().parent
CONFIG_PATH = BASE_DIR / "assets" / "main.cfg"
VERSION = "1.0.0"

# Set up global theme configuration
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class WinTweaksApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("WinTweaks - Professional Optimization Suite")
        self.geometry("850x520")
        self.resizable(False, False)

        # Load configuration settings on startup
        self.config = self.load_config()

        # Configure grid layout structure
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)

        # ==================== SIDEBAR ====================
        self.sidebar_frame = ctk.CTkFrame(self, width=210, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(4, weight=1)

        self.logo_label = ctk.CTkLabel(
            self.sidebar_frame, 
            text="WinTweaks", 
            font=ctk.CTkFont(size=22, weight="bold")
        )
        self.logo_label.grid(row=0, column=0, padx=20, pady=(25, 15))

        self.btn_dashboard = ctk.CTkButton(
            self.sidebar_frame, text="Dashboard", 
            command=lambda: self.select_tab("Dashboard")
        )
        self.btn_dashboard.grid(row=1, column=0, padx=20, pady=10)

        self.btn_performance = ctk.CTkButton(
            self.sidebar_frame, text="Performance", 
            command=lambda: self.select_tab("Performance")
        )
        self.btn_performance.grid(row=2, column=0, padx=20, pady=10)

        self.btn_privacy = ctk.CTkButton(
            self.sidebar_frame, text="Privacy", 
            command=lambda: self.select_tab("Privacy")
        )
        self.btn_privacy.grid(row=3, column=0, padx=20, pady=10)

        # Sidebar version display label
        self.version_label = ctk.CTkLabel(
            self.sidebar_frame, text=f"Version {VERSION}", 
            font=ctk.CTkFont(size=12), text_color="gray"
        )
        self.version_label.grid(row=5, column=0, padx=20, pady=20, sticky="s")

        # ==================== CONTENT AREA ====================
        self.content_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.content_frame.grid(row=0, column=1, sticky="nsew", padx=30, pady=25)
        
        # Load default view
        self.load_dashboard()

    def load_config(self):
        """Reads main.cfg and returns a dictionary of settings with safe defaults."""
        config = {
            "firstrun": "false",
            "theme": "Dark",
            "ultimate_performance": "false",
            "disable_animations": "false",
            "block_telemetry": "false",
            "disable_copilot": "false"
        }
        if CONFIG_PATH.exists():
            try:
                with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#") and "=" in line:
                            key, value = line.split("=", 1)
                            config[key.strip()] = value.strip()
            except Exception as e:
                print(f"[ERROR] Failed to read config: {e}")
        return config

    def save_config(self):
        """Writes current configuration state back to main.cfg."""
        try:
            with open(CONFIG_PATH, "w", encoding="utf-8") as f:
                f.write("# WinTweaks Configuration File\n")
                for key, value in self.config.items():
                    f.write(f"{key}={value}\n")
        except Exception as e:
            print(f"[ERROR] Failed to write config: {e}")

    def clear_content(self):
        """Clears current view widgets."""
        for widget in self.content_frame.winfo_children():
            widget.destroy()

    def select_tab(self, tab_name):
        """Switches content views dynamically."""
        self.clear_content()
        if tab_name == "Dashboard":
            self.load_dashboard()
        elif tab_name == "Performance":
            self.load_performance()
        elif tab_name == "Privacy":
            self.load_privacy()

    def load_dashboard(self):
        title = ctk.CTkLabel(self.content_frame, text="Welcome to WinTweaks", font=ctk.CTkFont(size=22, weight="bold"))
        title.pack(anchor="w", pady=(10, 10))

        desc = ctk.CTkLabel(
            self.content_frame, 
            text="Your all-in-one Windows optimization, privacy, and performance utility.\nSelect a category from the sidebar to start configuring your system.", 
            justify="left"
        )
        desc.pack(anchor="w", pady=(0, 20))

        # System info box showing live config states
        cfg_status = "Loaded Successfully" if CONFIG_PATH.exists() else "Missing!"
        admin_status = "Administrator (Elevated)" if is_admin_user() else "Standard User (Limited)"
        
        info_text = (
            f"System Overview:\n"
            f"• Privilege Level: {admin_status}\n"
            f"• Config Path: {CONFIG_PATH}\n"
            f"• App Version: {VERSION}\n\n"
            f"Saved Tweak States in main.cfg:\n"
            f"• Ultimate Performance: {self.config.get('ultimate_performance')}\n"
            f"• Disable Animations: {self.config.get('disable_animations')}\n"
            f"• Block Telemetry: {self.config.get('block_telemetry')}\n"
            f"• Disable Copilot: {self.config.get('disable_copilot')}"
        )
        
        info_box = ctk.CTkTextbox(self.content_frame, width=560, height=180, corner_radius=6)
        info_box.pack(anchor="w", pady=10)
        info_box.insert("0.0", info_text)
        info_box.configure(state="disabled")

    def load_performance(self):
        title = ctk.CTkLabel(self.content_frame, text="Performance Tweaks", font=ctk.CTkFont(size=22, weight="bold"))
        title.pack(anchor="w", pady=(10, 15))

        # Ultimate Performance Switch (State bound to config)
        self.switch_ultimate = ctk.CTkSwitch(self.content_frame, text="Enable Ultimate Performance Power Plan")
        self.switch_ultimate.pack(anchor="w", pady=12)
        if self.config.get("ultimate_performance") == "true":
            self.switch_ultimate.select()

        # Disable Animations Switch (State bound to config)
        self.switch_animations = ctk.CTkSwitch(self.content_frame, text="Disable Windows UI Animations for Extra Speed")
        self.switch_animations.pack(anchor="w", pady=12)
        if self.config.get("disable_animations") == "true":
            self.switch_animations.select()

        apply_btn = ctk.CTkButton(
            self.content_frame, text="Apply Performance Tweaks", 
            fg_color="#2fa572", hover_color="#248f5e", 
            command=self.apply_performance_tweaks
        )
        apply_btn.pack(anchor="w", pady=25)

    def load_privacy(self):
        title = ctk.CTkLabel(self.content_frame, text="Privacy & Telemetry", font=ctk.CTkFont(size=22, weight="bold"))
        title.pack(anchor="w", pady=(10, 15))

        # Block Telemetry Switch (State bound to config)
        self.switch_telemetry = ctk.CTkSwitch(self.content_frame, text="Block Windows Telemetry & Diagnostic Data Collection")
        self.switch_telemetry.pack(anchor="w", pady=12)
        if self.config.get("block_telemetry") == "true":
            self.switch_telemetry.select()

        # Disable Copilot Switch (State bound to config)
        self.switch_copilot = ctk.CTkSwitch(self.content_frame, text="Disable Windows Copilot & Cortana Integration")
        self.switch_copilot.pack(anchor="w", pady=12)
        if self.config.get("disable_copilot") == "true":
            self.switch_copilot.select()

        apply_btn = ctk.CTkButton(
            self.content_frame, text="Apply Privacy Tweaks", 
            fg_color="#2fa572", hover_color="#248f5e", 
            command=self.apply_privacy_tweaks
        )
        apply_btn.pack(anchor="w", pady=25)

    def apply_performance_tweaks(self):
        # Capture toggle states and update config dictionary
        self.config["ultimate_performance"] = "true" if self.switch_ultimate.get() == 1 else "false"
        self.config["disable_animations"] = "true" if self.switch_animations.get() == 1 else "false"
        
        # Save changes to main.cfg
        self.save_config()
        
        # TODO: Insert actual registry commands or script execution here!
        
        self.show_success_status("Performance Applied!")

    def apply_privacy_tweaks(self):
        # Capture toggle states and update config dictionary
        self.config["block_telemetry"] = "true" if self.switch_telemetry.get() == 1 else "false"
        self.config["disable_copilot"] = "true" if self.switch_copilot.get() == 1 else "false"
        
        # Save changes to main.cfg
        self.save_config()
        
        # TODO: Insert actual registry commands or script execution here!
        
        self.show_success_status("Privacy Applied!")

    def show_success_status(self, message):
        self.version_label.configure(text=message, text_color="#2fa572")
        self.after(3000, lambda: self.version_label.configure(text=f"Version {VERSION}", text_color="gray"))

def is_admin_user():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except Exception:
        return False

if __name__ == "__main__":
    app = WinTweaksApp()
    app.mainloop()
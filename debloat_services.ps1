#Requires -RunAsAdministrator
# ============================================================
#  Windows Services Debloat
#  Generated for your specific services list
#  Run as Administrator
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

function Set-Svc {
    param([string]$Name, [string]$Mode)
    $startVal = switch ($Mode) {
        "Disabled" { 4 }
        "Manual"   { 3 }
        "Auto"     { 2 }
    }
    # Try Set-Service first
    Set-Service -Name $Name -StartupType $Mode 2>$null
    # Also hammer registry directly (fixes _5b055 per-user services)
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$Name"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "Start" -Value $startVal 2>$null
    }
    # Stop it if disabling
    if ($Mode -eq "Disabled") {
        Stop-Service -Name $Name -Force 2>$null
    }
    Write-Host "  [$Mode] $Name" -ForegroundColor $(if ($Mode -eq "Disabled") {"Red"} elseif ($Mode -eq "Manual") {"Yellow"} else {"Green"})
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Services Debloat Script" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ─────────────────────────────────────────────
# DISABLE — Pure bloat / not needed
# ─────────────────────────────────────────────
Write-Host "[DISABLING BLOAT SERVICES]" -ForegroundColor Red
Write-Host ""

$disable = @(
    # Cortana / activation junk
    "AarSvc",           # Agent Activation Runtime (template)
    "AarSvc_5b055",     # Agent Activation Runtime (per-user)
    "AppReadiness",     # App Readiness
    "AssignedAccessManagerSvc", # Kiosk/assigned access

    # Bluetooth (disable if no BT devices — comment out if you use BT)
    "BthAvctpSvc",      # Bluetooth Audio Gateway
    "bthserv",          # Bluetooth Support Service
    "BluetoothUserService",
    "BluetoothUserService_5b055",

    # Enterprise / MDM garbage
    "BranchCache",
    "EntAppSvc",        # Enterprise App Management
    "dmwappushservice", # Device Management WAP Push
    "DmEnrollmentSvc",  # Device Management Enrollment
    "NcaSvc",           # Network Connectivity Assistant (DirectAccess)
    "NetlogonSvc",      # Netlogon — domain only
    "UevAgentService",  # User Experience Virtualization
    "wlpasvc",          # Local Profile Assistant
    "SharedAccess",     # Internet Connection Sharing

    # Windows backup / recovery
    "SDRSVC",           # Windows Backup
    "wbengine",         # Block Level Backup Engine

    # Xbox Live
    "XblAuthManager",   # Xbox Live Auth Manager
    "XblGameSave",      # Xbox Live Game Save
    "XboxNetApiSvc",    # Xbox Live Networking
    "XboxGipSvc",       # Xbox Accessory Manager

    # Hyper-V (disable if not running VMs)
    "HvHost",
    "vmickvpexchange",  # Hyper-V Data Exchange
    "vmicguestinterface",
    "vmicshutdown",     # Hyper-V Guest Shutdown
    "vmicheartbeat",
    "vmicvmsession",    # Hyper-V PowerShell Direct
    "vmicrdv",          # Hyper-V Remote Desktop
    "vmictimesync",     # Hyper-V Time Sync
    "vmicvss",          # Hyper-V Volume Shadow Copy

    # Telemetry / diagnostics upload
    "diagsvc",          # Diagnostic Execution Service
    "DiagTrack",        # Connected User Experiences & Telemetry
    "dmwappushservice",

    # Sensors (desktop — not needed)
    "SensorDataService",
    "SensrSvc",         # Sensor Monitoring
    "SensorService",

    # Smart card
    "SCardSvr",
    "ScDeviceEnum",
    "SCPolicySvc",

    # Remote Desktop / WinRM
    "TermService",      # Remote Desktop Services
    "SessionEnv",       # Remote Desktop Config
    "UmRdpService",     # Remote Desktop UserMode Port Redirector
    "WinRM",            # Windows Remote Management

    # Networking bloat
    "lltdsvc",          # Link-Layer Topology Discovery
    "NcdAutoSetup",     # Network Connected Devices Auto-Setup
    "SSDPSRV",          # SSDP Discovery
    "upnphost",         # UPnP Device Host
    "WFDSConMgrSvc",    # Wi-Fi Direct Services
    "dot3svc",          # Wired AutoConfig (802.1X — not enterprise)
    "Netlogon",

    # Maps / location
    "MapsBroker",       # Downloaded Maps Manager
    "lfsvc",            # Geolocation Service (already disabled)

    # Phone / messaging
    "PhoneSvc",         # Phone Service
    "MessagingService",
    "MessagingService_5b055",
    "RmSvc",            # Radio Management (not needed if WiFi/BT off)

    # Printing (comment out if you print)
    "Spooler",          # Print Spooler
    "PrintNotify",      # Printer Extensions
    "McpManagementService", # Universal Print

    # Misc bloat
    "AXInstSV",         # ActiveX Installer
    "tzautoupdate",     # Auto Time Zone Updater
    "CscService",       # Offline Files
    "CaptureService_5b055",
    "CellularTime",
    "CloudBackupRestoreSvc",
    "DPS",              # Diagnostic Policy — set manual below instead, skip here
    "EFS",              # Encrypting File System — only if you don't use EFS
    "embeddedmode",     # Embedded Mode
    "fdPHost",          # Function Discovery Provider Host
    "FDResPub",         # Function Discovery Resource Publication
    "fhsvc",            # File History
    "icssvc",           # Windows Mobile Hotspot
    "IpxlatCfgSvc",     # IP Translation Configuration
    "KPSSVC",           # Kerberos Local Key Distribution
    "WinHttpAutoProxySvc", # WinHTTP Web Proxy (careful — some apps need this)
    "wlidsvc",          # Microsoft Account Sign-in Assistant
    "MSiSCSI",          # Microsoft iSCSI Initiator
    "NaturalAuthentication",
    "Netman",           # Network Connections (manual below is safer)
    "p9rdr",            # Plan 9 Redirector (WSL)
    "PcaSvc",           # Program Compatibility Assistant — set manual
    "PerfHost",         # Performance Counter DLL Host
    "PACSVC",           # Parental Controls
    "SEMgrSvc",         # Payments and NFC
    "PenService_5b055",
    "perceptionsimulation", # Windows Perception Simulation (MR/HoloLens)
    "PNRPAutoReg",
    "wercplsupport",    # Problem Reports Control Panel
    "RasAuto",          # Remote Access Auto Connection
    "RasMan",           # Remote Access Connection Manager
    "RetailDemo",       # Retail Demo Service
    "seclogon",         # Secondary Logon
    "SstpSvc",          # Secure Socket Tunneling (SSTP VPN)
    "SharedRealitySvc",
    "SharedPCSvc",      # Shared PC Account Manager
    "SNMPTRAP",         # SNMP Trap
    "stisvc",           # Still Image Acquisition Events
    "TieringEngineService", # Storage Tiers Management
    "TapiSrv",          # Telephony
    "UdkUserSvc_5b055",
    "UserDataSvc",
    "UserDataSvc_5b055",
    "UnistoreSvc",
    "UnistoreSvc_5b055",
    "WalletService",
    "warpjitsvc",       # Warp JIT
    "WebClient",        # WebClient (WebDAV)
    "WiaRpc",           # Windows Image Acquisition
    "wisvc",            # Windows Insider Service
    "WMPNetworkSvc",    # Windows Media Player Network Sharing
    "WpnService",       # Windows Push Notifications (careful — disables toast notifs)
    "WpnUserService_5b055",
    "WWAN AutoConfig",
    "WwanSvc",
    "WorkFoldersSvc",
    "wbiosrvc",         # Windows Biometric Service
    "FrameServer",      # Windows Camera Frame Server
    "FrameServerMonitor",
    "wcncsvc",          # Windows Connect Now
    "Wecsvc",           # Windows Event Collector
    "WinDefend",        # Windows Defender (already disabled)
    "WdNisSvc",
    "WdBoot",
    "WdFilter",
    "wlpasvc",
    "TabletInputService", # Windows Ink (pen input)
    "SysMain",          # Superfetch — useless on SSD
    "TrkWks",           # Distributed Link Tracking Client
    "MSDTC",            # Distributed Transaction Coordinator
    "NetTcpPortSharing", # Net.Tcp Port Sharing (already disabled)
    "RemoteRegistry",   # Remote Registry (already disabled)
    "Fax",              # Fax
    "diagnosticshub.standardcollector.service",
    "WerSvc",           # Windows Error Reporting
    "wevtutil",
    "edgeupdate",       # Microsoft Edge Update
    "edgeupdatem",
    "MicrosoftEdgeElevationService"
)

foreach ($svc in $disable) {
    Set-Svc -Name $svc -Mode "Disabled"
}

# ─────────────────────────────────────────────
# SET TO MANUAL — run on demand only
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "[SETTING TO MANUAL]" -ForegroundColor Yellow
Write-Host ""

$manual = @(
    "BITS",             # Background Intelligent Transfer
    "wuauserv",         # Windows Update
    "TrustedInstaller", # Windows Modules Installer
    "UsoSvc",           # Update Orchestrator Service
    "WaaSMedicSvc",     # Windows Update Medic
    "DPS",              # Diagnostic Policy Service
    "WdiServiceHost",   # Diagnostic Service Host
    "WdiSystemHost",    # Diagnostic System Host
    "EapHost",          # Extensible Authentication Protocol
    "GraphicsPerfSvc",
    "gpsvc",            # Group Policy Client (keep manual — some apps need it)
    "PolicyAgent",      # IPsec Policy Agent
    "W32Time",          # Windows Time
    "swprv",            # Microsoft Software Shadow Copy Provider
    "SpaceManagementService", # Microsoft Storage Spaces
    "MozillaMaintenance",
    "OpenSSH Authentication Agent",
    "ssh-agent",
    "defragsvc",        # Optimize Drives
    "QWAVE",            # Quality Windows Audio Video Experience
    "SteelSeriesService",
    "VaultSvc",         # Credential Manager
    "Vds",              # Virtual Disk
    "VSS",              # Volume Shadow Copy
    "Winmgmt",          # Windows Management Instrumentation
    "WinHttpAutoProxySvc",
    "WmiApSrv",         # WMI Performance Adapter
    "wlansvc",          # WLAN AutoConfig — keep manual if on WiFi
    "NlaSvc",           # Network Location Awareness
    "CertPropSvc",      # Certificate Propagation
    "COMSysApp",        # COM+ System Application
    "dot3svc",          # Wired AutoConfig
    "DusmSvc",          # Data Usage
    "netprofm",         # Network List Service
    "PcaSvc",           # Program Compatibility Assistant
    "PortableDeviceEnumeratorService",
    "WPDBusEnum",
    "LicenseManager",   # Windows License Manager
    "ClipSVC",          # Client License Service
    "InstallService",   # Microsoft Store Install Service
    "TokenBroker",      # Web Account Manager
    "NgcSvc",           # Microsoft Passport
    "NgcCtnrSvc",       # Microsoft Passport Container
    "WbioSrvc"          # Windows Biometric (if you use Windows Hello PIN)
)

foreach ($svc in $manual) {
    Set-Svc -Name $svc -Mode "Manual"
}

# ─────────────────────────────────────────────
# PER-USER SERVICE TEMPLATES via registry
# Prevents them respawning on next login
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "[DISABLING PER-USER SERVICE TEMPLATES]" -ForegroundColor Magenta
Write-Host ""

$perUserTemplates = @(
    "AarSvc",
    "BcastDVRUserService",
    "BluetoothUserService",
    "CaptureService",
    "cbdhsvc",          # Clipboard User Service
    "CDPUserSvc",       # Connected Devices Platform User
    "ConsentUxUserSvc",
    "CredentialEnrollmentManagerUserSvc",
    "DevicePickerUserSvc",
    "DevicesFlowUserSvc",
    "MessagingService",
    "OneSyncSvc",       # Sync Host
    "PenService",
    "PrintWorkflowUserSvc",
    "UdkUserSvc",
    "UnistoreSvc",
    "UserDataSvc",
    "WpnUserService",
    "XboxGipSvc"
)

foreach ($template in $perUserTemplates) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$template"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "Start" -Value 4 2>$null
        Write-Host "  [Template Disabled] $template" -ForegroundColor Magenta
    }
}

# ─────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Done. Reboot recommended." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

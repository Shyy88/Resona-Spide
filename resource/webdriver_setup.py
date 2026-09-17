"""
Keyword library untuk auto-manage browser driver (geckodriver, chromedriver,
msedgedriver, dst) memakai library `webdriver-manager`.

Kenapa ini dibutuhkan:
- Sebelumnya Selenium mengandalkan driver (misal geckodriver) yang sudah
  ter-install manual dan ada di PATH. Ini merepotkan karena harus di-download
  manual dan sering "version mismatch" saat browser di komputer ter-update.
- Dengan webdriver-manager, driver yang cocok dengan versi browser akan
  di-download & di-cache otomatis saat test dijalankan.

Cara pakai di resource/config.resource:
    *** Settings ***
    Library    ./webdriver_setup.py

    *** Keywords ***
    Open Application
        ${driver_path}=    Get Driver Path    ${BROWSER}
        Open Browser    ${URL}    ${BROWSER}    executable_path=${driver_path}

Setiap public function di module ini otomatis menjadi keyword Robot Framework
(underscore pada nama function otomatis dibaca sebagai spasi oleh Robot,
jadi `get_driver_path` bisa dipanggil sebagai `Get Driver Path`).
"""

# Mapping alias browser -> driver manager yang sesuai.
# Key HARUS huruf kecil karena browser name akan di-lower() sebelum dicocokkan.
_SUPPORTED_BROWSERS = {
    "firefox": "firefox",
    "ff": "firefox",
    "headlessfirefox": "firefox",
    "chrome": "chrome",
    "googlechrome": "chrome",
    "headlesschrome": "chrome",
    "edge": "edge",
    "msedge": "edge",
}


def get_driver_path(browser):
    """Download (atau ambil dari cache) driver yang cocok untuk `browser`,
    lalu kembalikan path-nya sebagai string.

    Melempar ValueError jika browser tidak/belum didukung, supaya error-nya
    jelas ("browser X belum didukung") alih-alih error teknis dari
    webdriver-manager/Selenium yang membingungkan.
    """
    browser_key = _SUPPORTED_BROWSERS.get(str(browser).strip().lower())

    if browser_key == "firefox":
        from webdriver_manager.firefox import GeckoDriverManager

        return GeckoDriverManager().install()

    if browser_key == "chrome":
        from webdriver_manager.chrome import ChromeDriverManager

        return ChromeDriverManager().install()

    if browser_key == "edge":
        from webdriver_manager.microsoft import EdgeChromiumDriverManager

        return EdgeChromiumDriverManager().install()

    raise ValueError(
        "Browser '{0}' belum didukung oleh webdriver_setup.py. "
        "Browser yang didukung saat ini: firefox, chrome, edge. "
        "Tambahkan driver manager yang sesuai di resource/webdriver_setup.py, "
        "atau pasang driver-nya manual di PATH lalu panggil Open Browser "
        "tanpa argumen executable_path.".format(browser)
    )

/***********************************************************************\
*                                w32api.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                 Translated from MinGW Windows headers                 *
*                           by Stewart Gordon                           *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module tango.os.windows.c.w32api;

//version (build) { pragma(nolink); }


const __W32API_VERSION = 3.6;
const __W32API_MAJOR_VERSION = 3;
const __W32API_MINOR_VERSION = 6;

/*	These version identifiers are used to specify the minimum version of
 *	Windows that an application will support.
 *
 *	The programmer should set two version identifiers: one for the
 *	minimum Windows NT version and one for the minimum Windows 9x
 *	version.  If no Windows NT version is specified, Windows NT 4 is
 *	assumed.  If no Windows 9x version is specified, Windows 95 is
 *	assumed, unless WindowsNTonly, WindowsXP or Windows2003 is specified,
 *	implying that the application supports only Windows NT.
 */

// For Windows XP and later, assume no Windows 9x support
version (Windows2003) {
	const uint
		_WIN32_WINNT   = 0x502,
		_WIN32_WINDOWS = uint.max;

} else version (WindowsXP) {
	const uint
		_WIN32_WINNT   = 0x501,
		_WIN32_WINDOWS = uint.max;

} else {
	/*	for earlier Windows versions, separate version identifiers into
	 *	the NT and 9x lines
	 */
	version (Windows2000) {
		const uint _WIN32_WINNT = 0x500;
	} else {
		const uint _WIN32_WINNT = 0x400;
	}

	version (WindowsNTonly) {
		const uint _WIN32_WINDOWS = uint.max;
	} else version (WindowsME) {
		const uint _WIN32_WINDOWS = 0x500;
	} else version (Windows98) {
		const uint _WIN32_WINDOWS = 0x410;
	} else {
		const uint _WIN32_WINDOWS = 0x400;
	}
}

// Just a bit of syntactic sugar for the static ifs
const uint WINVER = _WIN32_WINDOWS < _WIN32_WINNT ?
                    _WIN32_WINDOWS : _WIN32_WINNT;
const bool _WIN32_WINNT_ONLY = _WIN32_WINDOWS == uint.max;

version (IE6) {
	const uint _WIN32_IE = 0x600;
} else version (IE56) {
	const uint _WIN32_IE = 0x560;
} else version (IE501) {
	const uint _WIN32_IE = 0x501;
} else version (IE5) {
	const uint _WIN32_IE = 0x500;
} else version (IE401) {
	const uint _WIN32_IE = 0x401;
} else version (IE4) {
	const uint _WIN32_IE = 0x400;
} else version (IE3) {
	const uint _WIN32_IE = 0x300;
} else static if (WINVER >= 0x410) {
	const uint _WIN32_IE = 0x400;
} else {
	const uint _WIN32_IE = 0;
}

unittest {
	printf("Windows NT version: %03x\n", _WIN32_WINNT);
	printf("Windows 9x version: %03x\n", _WIN32_WINDOWS);
	printf("IE version:         %03x\n", _WIN32_IE);
}

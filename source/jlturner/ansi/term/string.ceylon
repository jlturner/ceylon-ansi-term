"The bell character"
shared String bellString = "\\a";

"The control sequence introducer, defined as ESC["
shared String csi = "\\033[";

"Generate an ANSI Escape Code from a control code identifier and variable parameters"
shared String ansiEscapeCode(String controlCode, Object* parameters) {
	value controlParams = ";".join(parameters);
	return "``csi````controlParams````controlCode``";
}

"CUU - Cursor Up string"
shared String cuu(Integer rows = 1) {
	return ansiEscapeCode("A", rows);
}

"CUD - Cursor Down string"
shared String cud(Integer rows = 1) {
	return ansiEscapeCode("B", rows);
}

"CUF - Cursor Forward string"
shared String cuf(Integer columns = 1) {
	return ansiEscapeCode("C", columns);
}

"CUB - Cursor Back string"
shared String cub(Integer columns = 1) {
	return ansiEscapeCode("D", columns);
}

"CNL - Cursor Next Line string"
shared String cnl(Integer rows = 1) {
	return ansiEscapeCode("E", rows);
}

"CPL - Cursor Previous Line string"
shared String cpl(Integer rows = 1) {
	return ansiEscapeCode("F", rows);
}

"CHA - Cursor Horizontal Absolute string"
shared String cha(Integer columnPosition) {
	return ansiEscapeCode("G", columnPosition);
}

"CUP - Cursor Position string"
shared String cup(Integer row, Integer column) {
	return ansiEscapeCode("H", row, column);
}

"Modes for how Erase Display should work"
shared abstract class EraseDisplayMode(shared Integer modeNumber) 
		of cursorToEndOfScreen 
		| cursorToBeginningOfScreen 
		| entireScreen {}

"Mode makes Erase Display erase all text from the cursor to the end of the screen"
shared object cursorToEndOfScreen extends EraseDisplayMode(0) {}
"Mode makes Erase Display erase all text from the cursor to the beggining of the screen"
shared object cursorToBeginningOfScreen extends EraseDisplayMode(1) {}
"Mode makes Erase Display erase all text on the screen"
shared object entireScreen extends EraseDisplayMode(2) {}

"ED - Erase Display string"
shared String ed(EraseDisplayMode mode){
	return ansiEscapeCode("J", mode.modeNumber);
}

"Modes for how Erase in Line should work"
shared abstract class EraseInLineMode(shared Integer modeNumber) 
		of cursorToEndOfLine 
		| cursorToBeginningOfLine
		| entireLine {}

"Mode makes Erase in Line erase all text from the cursor to the end of the line"
shared object cursorToEndOfLine extends EraseInLineMode(0) {}
"Mode makes Erase in Line erase all text from the cursor to the beginning of the line"
shared object cursorToBeginningOfLine extends EraseInLineMode(1) {}
"Mode makes Erase in Line erase all text in the cursor's current line"
shared object entireLine extends EraseInLineMode(2) {}

"EL - Erase in Line string"
shared String el(EraseInLineMode mode) {
	return ansiEscapeCode("K", mode.modeNumber);
}

"SU - Scroll Up string"
shared String su(Integer lines = 1) {
	return ansiEscapeCode("S", lines);
}

"SD - Scroll Down string"
shared String sd(Integer lines = 1) {
	return ansiEscapeCode("T", lines);
}

"HVP - Horizontal And Vertical Position string (same as CUP)"
shared String hvp(Integer row, Integer column) {
	return ansiEscapeCode("f", row, column);
}

"SGR color codes"
shared abstract class SGRColor(shared Integer colorCode) 
		of defaultColor 
		| black
		| red
		| green
		| yellow
		| blue
		| magenta
		| cyan
		| white 
		| RGB {}
shared object defaultColor extends SGRColor(-1) {}
shared object black extends SGRColor(0) {}
shared object red extends SGRColor(1) {}
shared object green extends SGRColor(2) {}
shared object yellow extends SGRColor(3) {}
shared object blue extends SGRColor(4) {}
shared object magenta extends SGRColor(5) {}
shared object cyan extends SGRColor(6) {}
shared object white extends SGRColor(7) {}
shared class RGB(Integer r, Integer g, Integer b) extends SGRColor(16 + (36 * r) + (6 * g) + b) {
	Boolean inRange(Integer v) => v >= 0 && v < 6;
	assert(inRange(r), inRange(g), inRange(b));
}

"SGR display parameters"
shared abstract class SGRParameter()
		of reset
		| Bold
		| Underline
		| Blink
		| ForegroundColor
		| BackgroundColor
		| reverse {
	shared formal Object code;
}

shared object reset extends SGRParameter() {
	code => 0;
}
shared class Bold(Boolean enable) extends SGRParameter() {
	code => enable == true then 1 else 22;
}
shared class Underline(Boolean enable) extends SGRParameter() {
	code => enable then 4 else 24;
}
shared class Blink(Boolean enable) extends SGRParameter() {
	code => enable then 5 else 25;
}
shared class ForegroundColor(SGRColor color) extends SGRParameter() {
	code = function() { 
		switch (color)
		case (defaultColor) {
			return 39;
		}
		case (is RGB) {
			return "38;5;``color.colorCode``"; 
		}
		else {
			return 30 + color.colorCode;
		}
	};
}
shared class BackgroundColor(SGRColor color) extends SGRParameter() {
	code = function() { 
		switch (color)
		case (defaultColor) {
			return 49;
		}
		case (is RGB) {
			return "48;5;``color.colorCode``"; 
		}
		else {
			return 40 + color.colorCode;
		}
	};
}
shared object reverse extends SGRParameter() {
	code => 7;
}

"SGR - Select Graphic Rendition string"
shared String sgr(SGRParameter* params) {
	return ansiEscapeCode("m", *params);
}
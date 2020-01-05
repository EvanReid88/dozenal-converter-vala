# Dozenal / Decimal Converter Application (Vala, Gtk)
A simple desktop application for converting between decimal and dozenal representations of rational and irrational numbers.  
Dozenal or Duodecimal math is base 12, while decimal is base 10. Dozenal is represented as digets 0-9, X = 10 and E = 11.  
Precision of the converted value will match the precision of the input. (add 0's at the end of each input to increase precision)
  
This converter was built to practice using Vala and Gtk to write applications for the Elementary OS linux distribution.

![Dozenal Converter Screenshot](https://raw.github.com/evanreid88/dozenal-converter-vala/master/data/dozenal_converter_screenshot.png)

# Building and Installation
You will need the following dependencies. You can download them by running: ```sudo apt install elementary-sdk```
- libgtk-3.0-dev
- meson
- valac
  
In the root of this repository, run ```meson build``` to configure the build environment. Change to the /build directory and run ```ninja``` to build.
```
meson build --prefix=/usr
cd build
ninja
```
To install, use ```ninja install```, then run the application with ```com.github.evanreid88.dozenal-converter-vala```
```
sudo ninja install
com.evanreid88.dozenal-converter-vala
```

After installing on Elementary OS, you should be able to find the dozenal converter from the Applications Menu.
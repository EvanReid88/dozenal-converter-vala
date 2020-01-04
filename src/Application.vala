public class DuodecimalConvert : Gtk.Application {

  private static string duodecimal_digits = "0123456789XE";
  
  Regex decimal_regex;
  Regex duodecimal_regex;
  private Gtk.ApplicationWindow main_window;
  private Gtk.Label decimal_label;
  private Gtk.Label duodecimal_label;
  private Gtk.Entry decimal_text_field;
  private Gtk.Entry duodecimal_text_field;


  public DuodecimalConvert () {
    Object (
      application_id: "com.github.evanreid88.elementary-test-evanr",
      flags: ApplicationFlags.FLAGS_NONE
    );
  }

  protected override void activate () {
    main_window = new Gtk.ApplicationWindow (this);
    main_window.set_resizable(false);
    main_window.get_style_context().add_class("window");
    main_window.title = "Dozenal / Decimal Converter";

    connectWidgets();
    connectStyles();
    connectListeners();
    main_window.show_all ();
  }

  private void connectWidgets() {

    // labels and entry fields
    decimal_label = new Gtk.Label("Decimal: ");
    decimal_label.get_style_context().add_class("label");
    decimal_label.margin = 6;
    decimal_label.margin_top = 10;

    decimal_text_field = new Gtk.Entry();
    decimal_text_field.get_style_context().add_class("entry");
    decimal_text_field.margin = 6;
    decimal_text_field.margin_top = 10;
    decimal_text_field.set_width_chars(30);

    duodecimal_label = new Gtk.Label("Dozenal: ");
    duodecimal_label.get_style_context().add_class("label");
    duodecimal_label.margin = 6;

    duodecimal_text_field = new Gtk.Entry();
    duodecimal_text_field.get_style_context().add_class("entry");
    duodecimal_text_field.margin = 6;
    duodecimal_text_field.set_width_chars(30);

    // TODO add toggle information button, add styles
    var info_label = new Gtk.Label("Precision is truncated to the input precision.");
    info_label.margin_bottom = 6;

    // orientation
    var hlist = new Gtk.Grid();
    var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 20);
    var dozenal_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 20);

    hbox.pack_start(decimal_label, true, true, 0);
    hbox.pack_start(decimal_text_field, true, true, 0);

    dozenal_box.pack_start(duodecimal_label, true, true, 0);
    dozenal_box.pack_start(duodecimal_text_field, true, true, 0);

    hlist.attach(hbox, 1, 1, 1, 1);
    hlist.attach(dozenal_box, 1, 2, 1, 1);
    hlist.attach(info_label, 1, 3, 1,1);
    main_window.add(hlist);
  }

  private void connectStyles() {
    Gtk.CssProvider css_provider = new Gtk.CssProvider();
    string path = "styles.css";
    // test if the css file exist
    if (FileUtils.test (path, FileTest.EXISTS))
    {
      try {
        css_provider.load_from_path(path);
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), 
                                           css_provider, 
                                           Gtk.STYLE_PROVIDER_PRIORITY_USER);
      } catch (Error e) {
        error ("Cannot load CSS stylesheet: %s", e.message);
      }
    }
  }

  private void connectListeners() {

    try {
      decimal_regex = new GLib.Regex("^-?[1-9]*[0-9]*(\\.)?[0-9]*$");
    } catch (Error e) {
      error ("Cannot load regex: %s", e.message);
    }

    try {
      duodecimal_regex = new Regex("^-?[0-9XE]*(\\.)?[0-9XE]*$");
    } catch (Error e) {
      error ("Cannot load regex: %s", e.message);
    }

    decimal_text_field.changed.connect(() => {
      if (decimal_text_field.editable) {
        string entry = decimal_text_field.text;
        if (decimal_regex.match(entry)) {
          duodecimal_text_field.editable = false;
          string dozenal = decimalToDuodecimal(entry);
          duodecimal_text_field.set_text(dozenal);
          duodecimal_text_field.editable = true;
        } else {
          decimal_text_field.set_text(entry[0:entry.length - 1]);
        }
      }
    });

    duodecimal_text_field.changed.connect(() => {
      if (duodecimal_text_field.editable) {
        string entry = duodecimal_text_field.text;
        if (duodecimal_regex.match(entry)) {
          decimal_text_field.editable = false;
          string duodecimal = duodecimalToDecimal(entry);
          decimal_text_field.set_text(duodecimal);
          decimal_text_field.editable = true;
        } else {
          duodecimal_text_field.set_text(entry[0:entry.length - 1]);
        }
      }
    });
  }

  // convert integer portion of decimal to duodecimal
  private string intDecimalToDuodecimal(double intval) {
    string res = "";
    long R;
    double Q = Math.floor(intval.abs());
    while (true) {
      R = (long)(Q % 12);
      res = duodecimal_digits[R:R+1] + res;
      Q = (Q - R) / 12;
      if (Q == 0) break;
    }

    if (intval < 0) {
      res = "-" + res;
    }

    return res;
  }

  // convert fraction portion of decimal to duodecimal
  private string intFractionToDuodecimal(string frac) {
    int len = frac.length;
    double fracnum = double.parse("0." + frac);
    string res = "";

    while (len > 0) {
      double v = 0;
      double n = fracnum * 12;
      if (len > 1) {
        v = Math.floor(n);
      } else {
        v = Math.round(n);
      }
      fracnum = n - v;
      res += intDecimalToDuodecimal(v);
      len--;
    }
    return res;
  }

  // convert a decimal to duodecimal 
  private string decimalToDuodecimal(string dec) {
    if (dec == "" || dec == "-") return dec;
    
    string[] parts = dec.split(".", 2);
    string intpart = parts[0];
    string fracpart = parts[1];

    string res = intDecimalToDuodecimal(double.parse(intpart));

    if (parts.length > 1 && fracpart.length > 0) {
      res += "." + intFractionToDuodecimal(fracpart);
    }

    return res;
  }
  
  // convert integer portion of duodecimal string to decimal
  private double intDuodecimalToDecimal(string intpart) {
    bool neg = false;
    string returnint = intpart;
    if (intpart.get_char(0) == '-') {
      string dstring = intpart.substring(1, intpart.char_count() - 1);
      returnint = dstring;
      neg = true;
    }

    double res = 0;
    int n = 0;
    for (int i = 0; i < returnint.char_count(); i++) {
      unichar d = returnint.get_char(i);
      if (d == 'E') {
        n = 11;
      } else if (d == 'X') {
        n = 10;
      } else {
        n = int.parse(returnint[i:i+1]);
      }
      res += n*Math.pow(12.00, (returnint.length - i - 1));
    }

    if (neg) {
      res = res * -1;
    }

    return res;
  }
  
  // convert duodecimal to decimal
  private string duodecimalToDecimal(string doz) {
    if (doz == "" || doz == "-") { return doz; }

    string[] parts = doz.split(".", 2);
    string integer = parts[0];
    string fraction = parts[1];

    int div_times = 0;
    double prec = 0;
    if (parts.length > 1) {
      prec = div_times = fraction.char_count();
      integer = integer + fraction;
    }

    double result = intDuodecimalToDecimal(integer);

    while (div_times > 0) {
      result = result / 12;
      div_times--;
    }
    result *= Math.pow(10, prec);
    result = Math.round(result);
    result = result / Math.pow(10, prec);

    char[] buf = new char[double.DTOSTR_BUF_SIZE];
    unowned string str = result.to_str(buf);
    string resstr = str;

    return resstr;
  }

  public static int main (string[] args) {
    Gtk.init(ref args);
    var app = new DuodecimalConvert ();
    return app.run (args);
  }
}

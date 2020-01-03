public class MyApp : Gtk.Application {

  int textfield_events = 4195088;
  string tempstr = "";

  public MyApp () {
    Object (
      application_id: "com.github.evanreid88.elementary-test-evanr",
      flags: ApplicationFlags.FLAGS_NONE
    );
  }

  protected override void activate () {
    var main_window = new Gtk.ApplicationWindow (this);
    main_window.set_resizable(false);
    //main_window.default_height = 300;
    //main_window.default_width = 500;
    main_window.title = "Dozenal Converter";

    var decimal_labal = new Gtk.Label("Decimal: ");
    decimal_labal.margin = 8;

    var text_field = new Gtk.Entry();
    text_field.margin = 8;
    text_field.set_width_chars(30);

    //  var button_hello = new Gtk.Button.with_label("Convert");
    //  button_hello.margin = 12;
    //  button_hello.clicked.connect(() => {
    //    button_hello.label = "Hello World!";
    //    button_hello.sensitive = false;
    //  });	

    var dozenal_label = new Gtk.Label("Dozenal: ");
    dozenal_label.margin = 8;

    var dozenal_text_field = new Gtk.Entry();
    dozenal_text_field.margin = 8;
    dozenal_text_field.set_width_chars(30);

    var hlist = new Gtk.Grid();
    var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 20);
    var dozenal_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 20);

    text_field.changed.connect(() => {
      // TODO check for non numerical values
      // TODO convert dozenal to decimal  
      if (text_field.editable) {
        dozenal_text_field.editable = false;

      string entry = text_field.text;
      string dozenal = ConvertToDuodecimal(entry);
      dozenal_text_field.set_text(dozenal);

      dozenal_text_field.editable = true;
      }
    });

    dozenal_text_field.changed.connect(() => {
      if (dozenal_text_field.editable) {
        text_field.editable = false;
        string entry = dozenal_text_field.text;
        string duodecimal = DuodecimalToDecimal(entry);
        text_field.set_text(duodecimal);
        text_field.editable = true;
      }
    });


    hbox.pack_start(decimal_labal, true, true, 0);
    hbox.pack_start(text_field, true, true, 0);

    dozenal_box.pack_start(dozenal_label, true, true, 0);
    dozenal_box.pack_start(dozenal_text_field, true, true, 0);

    hlist.attach(hbox, 1, 1, 1, 1);
    hlist.attach(dozenal_box, 1, 2, 1, 1);
    main_window.add(hlist);

    main_window.show_all ();
  }

  public string ConvertToDuodecimal(string nstring) {

    string chars = "0123456789XE";
    string sign = " ";
    double n = double.parse(nstring);

    if (n < 0) {
      n = n.abs();
      sign = "-";
    }

    double quotient = Math.floor(n);
    double fractional = n - quotient;
    double remainder;
    
    var integer = "";
    while (quotient != 0) {
      remainder = quotient % 12.00;
      quotient = Math.floor(quotient / 12.00);
      integer = chars[(int)remainder : (int)remainder + 1] + integer;
    }

    var decimal = ".";

    if (fractional > 0.0) {
      remainder = fractional;

      int range = nstring.split(".")[1].char_count() + 1;

      for (int i = 0; i < range; i++) {
        
        quotient = Math.floor(remainder * 12.00);
        remainder = (remainder * 12.00) - quotient;

        decimal += chars[(int)quotient : (int)quotient + 1];
      }

      if (remainder > 0.5) {
        decimal += "1";
      }
    }

    return sign + integer + decimal;
  }

  public double IntDuodecimalToDecimal(string intpart) {
    bool neg = false;
    if (intpart.get_char(0) == '-') {
      string dstring = intpart.substring(1, intpart.char_count() - 1);
      intpart = dstring;
      print(intpart);
      neg = true;
    }

    double res = 0;
    int n = 0;
    for (int i = 0; i < intpart.char_count(); i++) {
      unichar d = intpart.get_char(i);
      if (d == 'E') {
        n = 11;
      } else if (d == 'X') {
        n = 10;
      } else {
        n = int.parse(intpart[i:i+1]);
      }
      res += n*Math.pow(12.00, (intpart.length - i - 1));
    }

    //  if (neg) {
    //    res = -res;
    //  }

    //  char[] buf = new char[double.DTOSTR_BUF_SIZE];
    //  unowned string str = res.to_str(buf);
    //  string resstr = str;

    //  if (neg) {
    //    resstr = string.join("-", str);
    //  }

    return res;
  }

  public string DuodecimalToDecimal(string doz) {
    if (doz == "" || doz == "-") { return doz; }
    string[] parts = doz.split(".");
    string integer = parts[0];
    string fraction = parts[1];

    int div_times = 0;
    double prec = 0;
    if (parts.length > 1) {
      prec = div_times = fraction.char_count();
      integer = integer + fraction;
    }

    double result = IntDuodecimalToDecimal(integer);

    while (div_times > 0) {
      result = result / 12;
      div_times--;
    }
    result *= Math.pow(10, prec);
    result = Math.round(result);
    result = result / Math.pow(10, prec);

    char[] buf = new char[double.DTOSTR_BUF_SIZE];
    unowned string str = result.to_str(buf);
    return str;
  }

  public static int main (string[] args) {
    var app = new MyApp ();
    return app.run (args);
  }
}

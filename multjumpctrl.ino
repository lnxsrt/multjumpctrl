/* Multipler Jumper Control by lnxsrt 2019 */

#define SERIAL_COM_PORT_SPEED 9600L

String cmd;
byte pin_val[12] = {2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2};

void set_pin(byte pin_num, byte new_pin_val)
{
  if (new_pin_val > 1)
  {
    pinMode(pin_num, INPUT);
    new_pin_val = 2;
  }
  else
  {
    pinMode(pin_num, OUTPUT);
    digitalWrite(pin_num, new_pin_val);
  }
  pin_val[pin_num - 2] = new_pin_val;
}

void setup()
{
  Serial.begin(SERIAL_COM_PORT_SPEED);
  for (byte i = 0; i < sizeof(pin_val) - 1; i++)
  {
    set_pin(i + 2, pin_val[i]);
  }
}

void loop()
{
  if (Serial.available())
  {
    char rawdata = Serial.read();
    if (rawdata != '\r')
    {
      cmd += rawdata;
    }
    else
    {
      String args = cmd.substring(cmd.indexOf(",") + 1);
      byte cmd_b = cmd.substring(0, cmd.indexOf(",")).toInt();
      byte arg1_index;
      byte arg1;
      byte arg2_index;
      byte arg2;
      switch (cmd_b)
      {
        case 1:
          arg1 = args.toInt();
          Serial.print(arg1);
          Serial.print(",");
          Serial.print(pin_val[arg1 - 2]);
          Serial.print(",");
          Serial.println("0");
          break;
        case 2:
          arg1_index = args.indexOf(",");
          arg1 = args.substring(0, arg1_index).toInt();
          arg2_index = args.indexOf(",", arg1_index + 1);
          arg2 = args.substring(arg1_index + 1, arg2_index).toInt();
          set_pin(arg1, arg2);
          Serial.println("0");
          break;
        default:
          Serial.println("1");
          break;
      }
      cmd = "";
    }
  }
}

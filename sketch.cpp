String a;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  a = "";
}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.write('a');
  a += "a";
  delay(400);
}

#include <iostream>
#include <string>
bool is_legal_string(std::string s) {
  if (s.size() < 2) {
    return false;
  }
  int cnt_0 = 0;
  for (char ch : s) {
    if (ch != '0' && ch != '1') {
      return false;
    }
    if (ch == '0') {
      cnt_0++;
    }
  }
  if (!cnt_0) {
    return false;
  }
  return true;
}

int main() {
  std::string s = "01";
  std::cout << is_legal_string(s) << std::endl;
  return 0;
}

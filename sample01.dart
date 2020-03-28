//使用dart，尝试实现生产者消费者模型。
//Day01

import 'dart:async';
import 'dart:math';

Random r = Random();

const int magicCookTime = 1000 ;

class Baker {
  String name ;
  Baker(this.name);

  int cookiesNum = 0;

  Future<Cookie> makeCookie() async{
    return  Future<Cookie>.delayed (Duration(milliseconds: r.nextInt(1000)),()  {
      cookiesNum++;
      return Cookie.generate();
    });
  }

}

int cookieId = 0;
class Cookie {
  num id ;
  Cookie.generate() {
    id = cookieId++;
  }
}

class Customer {
  String name ;
  int needs ;
  Customer(this.name,this.needs);

  Customer.coming(name,needs) {
    this.name = name;
    this.needs = needs ;
    p(toString() + " , is coming !");
  }

  @override
  String toString() {
    return 'Customer{name: $name, needs: $needs}';
  }

  leaving(){
    p(this.toString() + " , is leaving !");
  }

}

const int magicOpenTime = 30 ;


main() {
  p("start!");

  open();
  Future.delayed(Duration(seconds: magicOpenTime),(){
    close();
  }).catchError((err){
    p(err);
  });

  p("end!");
}

bool isOpen = false ;
Baker baker;
List<Cookie> listCookies = [];
List<Customer> listCustomers = [];
int numOfCookies = 0 ;

//开始营业
open() {
  isOpen = true ;
  baker =  Baker("Tony");

  startCooking();
  customerIsComing();

}

//关门
close ()  {
  isOpen = false ;
//  settlement();

  p("close");
}

settlement() {
  p("做了 $numOfCookies 个曲奇，来了 $numOfCustomers 个客户，卖了 $numOfSellCookies 个曲奇，最多使 $numOfMaxWaitingCustomer 个客户同时等位。");
}

startCooking() async{

  while (isOpen || listCustomers.length>0 ) {
    await baker.makeCookie().then((cookie) {

      numOfCookies++ ;

      listCookies.add(cookie);
      selling();

    }).catchError((err) {
      p(err);
    });
  }


}

const List<String> customerName = ["LiLei", "HanMeiMei" ,"LinTao","WeiHua","Jim","Kate","Lily","Lucy","Ann","Tom"];
const int magicNeeds = 5;
const int magicCustomerGap = 3000 ;

int numOfCustomers = 0 ;

customerIsComing() async {
  while (isOpen) {

    await Future.delayed(Duration(milliseconds: r.nextInt(magicCustomerGap)),(){
      if (isOpen) {
        return Customer.coming(customerName[r.nextInt(customerName.length)],r.nextInt(magicNeeds) + 1);
      } else {
        return null;
      }
    }).then((customer) {

      if ( customer != null ) {
        numOfCustomers++;

        listCustomers.add(customer);

        selling();
      }

    }).catchError((err) {
      p(err);
    });

  }
}

int numOfSellCookies = 0 ;
int numOfMaxWaitingCustomer = 0;

selling() {
  bool flag = true ;

  while (flag && listCustomers.length > 0 ) {//有顾客在等位,取出第一个顾客

    if (numOfMaxWaitingCustomer<listCustomers.length){
      numOfMaxWaitingCustomer = listCustomers.length;
    }

    Customer c1 = listCustomers[0];

    if (listCookies.length > c1.needs) {//库存充足
      numOfSellCookies += c1.needs;
      listCookies.removeRange(0,c1.needs);
      listCustomers.remove(c1);
      c1.leaving();
    } else {
      flag = false ;
    }

  }

  if (!isOpen) settlement();

}

void p(String info) {
  print(DateTime.now().toString() + " || " + info);
}


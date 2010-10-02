require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Ofx do
  TEST_FILE = File.expand_path(File.dirname(__FILE__) + '/../../data/Money.ofx')
  
  TEST_DATA = <<-DATA
  OFXHEADER:100
  DATA:OFXSGML
  VERSION:102
  SECURITY:NONE
  ENCODING:USASCII
  CHARSET:1252
  COMPRESSION:NONE
  OLDFILEUID:NONE
  NEWFILEUID:NONE
  <OFX>
    <SIGNONMSGSRSV1>
      <SONRS>
        <STATUS>
          <CODE>0
          <SEVERITY>INFO
        </STATUS>
        <DTSERVER>20100818142914[-5:EST]
        <LANGUAGE>ENG
      </SONRS>
    </SIGNONMSGSRSV1>
    <BANKMSGSRSV1>
      <STMTTRNRS>
        <TRNUID>0
        <STATUS>
          <CODE>0
          <SEVERITY>INFO
        </STATUS>
        <STMTRS>
          <CURDEF>USD
            <BANKACCTFROM>
                <BANKID>074014187
                <ACCTID>134582200
                <ACCTTYPE>CHECKING
            </BANKACCTFROM>
          <BANKTRANLIST>
            <DTSTART>20100801000000[-5:EST]
            <DTEND>20100817000000[-5:EST]
              <STMTTRN>
                <TRNTYPE>CASH
                <DTPOSTED>20100802000000[-5:EST]
                <TRNAMT>-15.33
                <FITID>20100802000000[-5:EST]*-15.33*0**External Withdrawal HSBC RS -
                <NAME>External Withdrawal HSBC RS -  
                                                          <MEMO>Online Pmt
              </STMTTRN>
              <STMTTRN>
                <TRNTYPE>CASH
                <DTPOSTED>20100802000000[-5:EST]
                <TRNAMT>-108.22
                <FITID>20100802000000[-5:EST]*-108.22*0**External Withdrawal AT+T -
                <NAME>External Withdrawal AT+T -  
                                                          <MEMO>PAYMENT
              </STMTTRN>
              <STMTTRN>
                <TRNTYPE>POS
                <DTPOSTED>20100807000000[-5:EST]
                <TRNAMT>-71.89
                <FITID>20100807000000[-5:EST]*-71.89*13**Point Of Sale Withdrawal HEB
                <NAME>Point Of Sale Withdrawal HEB  
                                                          <MEMO>GROCERY #161 AUSTIN TXUS
              </STMTTRN>
          </BANKTRANLIST>
          <LEDGERBAL>
            <BALAMT>1406.33
            <DTASOF>20100818142914[-5:EST]
          </LEDGERBAL>
          <AVAILBAL>
            <BALAMT>1406.33
            <DTASOF>20100818142914[-5:EST]
          </AVAILBAL>
        </STMTRS>
      </STMTTRNRS>
    </BANKMSGSRSV1>
  </OFX>
DATA

  before( :all ) do
    @ofx = Ofx.new( TEST_DATA )
  end

  it "parses a valid Ofx file" do
    Ofx.parse_file( TEST_DATA )
  end
  
  it "returns the account number" do
    @ofx.account_number.should == '134582200'
  end
  
  it "returns the correct number of transactions" do
    @ofx.transactions.size.should == 3
  end
  
  it "returns the correct account balance" do
    @ofx.account_balance.should == 1406.33
  end
  
  it "returns valid transactions" do
    account = Factory(:account)
    @ofx.transactions.each do |transaction|
      transaction.account = account
      transaction.valid?.should == true
    end
  end
  
  
end
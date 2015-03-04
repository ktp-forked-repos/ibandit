require 'spec_helper'

describe Ibandit::IBANAssembler do
  shared_examples_for 'allows round trips' do |iban_code|
    let(:iban) { Ibandit::IBAN.new(iban_code) }
    let(:args) do
      {
        country_code:   iban.country_code,
        account_number: iban.account_number,
        branch_code:    iban.branch_code,
        bank_code:      iban.bank_code
      }.reject { |_key, value| value.nil? }
    end

    it 'successfully reconstructs the IBAN' do
      expect(described_class.assemble(args)).to eq(iban.iban)
    end
  end

  describe '.assemble' do
    subject(:assemble) { described_class.assemble(args) }
    let(:args) { { country_code: 'ES' } }

    context 'without a country_code' do
      let(:args) { { bank_code: 1 } }
      it { is_expected.to be_nil }
    end

    context 'with an unsupported country_code' do
      let(:args) { { country_code: 'FU' } }
      it { is_expected.to be_nil }
    end

    context 'with AT as the country_code' do
      let(:args) do
        {
          country_code: 'AT',
          account_number: '00234573201',
          bank_code: '19043'
        }
      end

      it { is_expected.to eq('AT611904300234573201') }

      it_behaves_like 'allows round trips', 'AT61 1904 3002 3457 3201'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without an bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with BE as the country_code' do
      let(:args) { { country_code: 'BE', account_number: '510007547061' } }

      it { is_expected.to eq('BE62510007547061') }

      it_behaves_like 'allows round trips', 'BE62 5100 0754 7061'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with CY as the country_code' do
      let(:args) do
        {
          country_code: 'CY',
          account_number: '0000001200527600',
          bank_code: '002',
          branch_code: '00128'
        }
      end

      it { is_expected.to eq('CY17002001280000001200527600') }

      it_behaves_like 'allows round trips', 'CY17 0020 0128 0000 0012 0052 7600'

      context 'without an branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to eq('CY040020000001200527600') }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without an bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with DE as the country_code' do
      let(:args) do
        { country_code: 'DE',
          bank_code: '37040044',
          account_number: '0532013000' }
      end

      it { is_expected.to eq('DE89370400440532013000') }

      it_behaves_like 'allows round trips', 'DE89 3704 0044 0532 0130 00'

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with EE as the country_code' do
      let(:args) do
        {
          country_code: 'EE',
          bank_code: '22',
          account_number: '00221020145685'
        }
      end

      it { is_expected.to eq('EE382200221020145685') }

      it_behaves_like 'allows round trips', 'EE38 2200 2210 2014 5685'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with ES as the country_code' do
      let(:args) do
        {
          country_code: 'ES',
          bank_code: '2310',
          branch_code: '0001',
          account_number: '180000012345'
        }
      end

      it { is_expected.to eq('ES8023100001180000012345') }

      it_behaves_like 'allows round trips', 'ES80 2310 0001 1800 0001 2345'

      context 'without a bank_code or branch code' do
        before { args.delete(:bank_code) }
        before { args.delete(:branch_code) }
        before { args[:account_number] = '23100001180000012345' }

        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with FI as the country_code' do
      let(:args) do
        { country_code: 'FI', bank_code: '123456', account_number: '00000785' }
      end

      it { is_expected.to eq('FI2112345600000785') }

      it_behaves_like 'allows round trips', 'FI21 1234 5600 0007 85'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with FR as the country_code' do
      let(:args) do
        {
          country_code: 'FR',
          bank_code: '20041',
          branch_code: '01005',
          account_number: '0500013M02606'
        }
      end

      it { is_expected.to eq('FR1420041010050500013M02606') }

      it_behaves_like 'allows round trips', 'FR14 2004 1010 0505 0001 3M02 606'

      context 'without the rib key in the account number' do
        before { args[:account_number] = '0500013M026' }
        specify { expect(Ibandit::IBAN.new(assemble)).to_not be_valid }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with GB as the country_code' do
      let(:args) do
        {
          country_code: 'GB',
          bank_code: 'BARC',
          branch_code: '200000',
          account_number: '00579135'
        }
      end

      it { is_expected.to eq('GB07BARC20000000579135') }

      it_behaves_like 'allows round trips', 'GB07 BARC 2000 0000 5791 35'

      context 'with the bank_code supplied manually' do
        before { args.merge!(bank_code: 'BARC') }
        it { is_expected.to eq('GB07BARC20000000579135') }
      end

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'with a non-numeric branch code' do
        before { args[:branch_code] = 'abc123' }
        it { is_expected.to be_nil }
      end
    end

    context 'with GR as the country_code' do
      let(:args) do
        {
          country_code: 'GR',
          bank_code: '011',
          branch_code: '0125',
          account_number: '0000000012300695'
        }
      end

      it { is_expected.to eq('GR1601101250000000012300695') }

      it_behaves_like 'allows round trips', 'GR16 0110 1250 0000 0001 2300 695'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with IE as the country_code' do
      let(:args) do
        { country_code: 'IE',
          bank_code: 'AIBK',
          branch_code: '931152',
          account_number: '12345678' }
      end

      it { is_expected.to eq('IE29AIBK93115212345678') }

      it_behaves_like 'allows round trips', 'IE29 AIBK 9311 5212 3456 78'

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with IT as the country_code' do
      let(:args) do
        {
          country_code: 'IT',
          bank_code: '05428',
          branch_code: '11101',
          account_number: '000000123456'
        }
      end

      it { is_expected.to eq('IT60X0542811101000000123456') }

      it_behaves_like 'allows round trips', 'IT60 X054 2811 1010 0000 0123 456'

      context 'with an explicitly passed check digit' do
        before { args[:check_digit] = 'Y' }
        it { is_expected.to eq('IT64Y0542811101000000123456') }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with LT as the country_code' do
      let(:args) do
        {
          country_code: 'LT',
          account_number: '11101001000',
          bank_code: '10000'
        }
      end

      it { is_expected.to eq('LT121000011101001000') }

      it_behaves_like 'allows round trips', 'LT12 1000 0111 0100 1000'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with LU as the country_code' do
      let(:args) do
        {
          country_code: 'LU',
          account_number: '9400644750000',
          bank_code: '001'
        }
      end

      it { is_expected.to eq('LU280019400644750000') }

      it_behaves_like 'allows round trips', 'LU28 0019 4006 4475 0000'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with LV as the country_code' do
      let(:args) do
        {
          country_code: 'LV',
          account_number: '1234567890123',
          bank_code: 'BANK'
        }
      end

      it { is_expected.to eq('LV72BANK1234567890123') }

      it_behaves_like 'allows round trips', 'LV72 BANK 1234 5678 9012 3'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with MC as the country_code' do
      let(:args) do
        {
          country_code: 'MC',
          bank_code: '20041',
          branch_code: '01005',
          account_number: '0500013M02606'
        }
      end

      it { is_expected.to eq('MC9320041010050500013M02606') }

      it_behaves_like 'allows round trips', 'MC93 2004 1010 0505 0001 3M02 606'

      context 'without the rib key in the account number' do
        before { args[:account_number] = '0500013M026' }
        specify { expect(Ibandit::IBAN.new(assemble)).to_not be_valid }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with MT as the country_code' do
      let(:args) do
        {
          country_code: 'MT',
          bank_code: 'MMEB',
          branch_code: '44093',
          account_number: '000000009027293051'
        }
      end

      it { is_expected.to eq('MT98MMEB44093000000009027293051') }

      it_behaves_like(
        'allows round trips',
        'MT98 MMEB 4409 3000 0000 0902 7293 051'
      )

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'with a non-numeric branch code' do
        before { args[:branch_code] = 'abc123' }
        it { is_expected.to be_nil }
      end
    end

    context 'with NL as the country_code' do
      let(:args) do
        {
          country_code: 'NL',
          account_number: '0417164300',
          bank_code: 'ABNA'
        }
      end

      it { is_expected.to eq('NL91ABNA0417164300') }

      it_behaves_like 'allows round trips', 'NL91 ABNA 0417 1643 00'

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end

      context 'without an bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end
    end

    context 'with PT as the country_code' do
      let(:args) do
        {
          country_code: 'PT',
          bank_code: '0002',
          branch_code: '0023',
          account_number: '0023843000578'
        }
      end

      it { is_expected.to eq('PT50000200230023843000578') }

      it_behaves_like 'allows round trips', 'PT50 0002 0023 0023 8430 0057 8'

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with SI as the country_code' do
      let(:args) do
        {
          country_code: 'SI',
          bank_code: '19100',
          account_number: '0000123438'
        }
      end

      it { is_expected.to eq('SI56191000000123438') }

      it_behaves_like 'allows round trips', 'SI56 1910 0000 0123 438'

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with SK as the country_code' do
      let(:args) do
        {
          country_code: 'SK',
          bank_code: '1200',
          account_number: '0000198742637541'
        }
      end

      it { is_expected.to eq('SK3112000000198742637541') }

      it_behaves_like 'allows round trips', 'SK31 1200 0000 1987 4263 7541'

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end

    context 'with SM as the country_code' do
      let(:args) do
        {
          country_code: 'SM',
          bank_code: '05428',
          branch_code: '11101',
          account_number: '000000123456'
        }
      end

      it { is_expected.to eq('SM88X0542811101000000123456') }

      it_behaves_like 'allows round trips', 'SM88 X054 2811 1010 0000 0123 456'

      context 'without a bank_code' do
        before { args.delete(:bank_code) }
        it { is_expected.to be_nil }
      end

      context 'without a branch_code' do
        before { args.delete(:branch_code) }
        it { is_expected.to be_nil }
      end

      context 'without an account_number' do
        before { args.delete(:account_number) }
        it { is_expected.to be_nil }
      end
    end
  end
end

module ResidenceNumberValidator
  WEIGHTS = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5, 0]

  class << self
    def check_sum(id)
      id.chars.each_with_index.map { |n, i| n.to_i * WEIGHTS[i] }.reduce(:+)
    end

    def is_check_sum_valid(id)
      checkSum = check_sum(id)
      remainder = ((11 - (checkSum % 11)) % 10) - id[-1].to_i

      return remainder == 0
    end

    def is_length_valid(id)
      id.size == 13
    end

    def is_valid_date_str(date_str)
      begin
        Date.parse(date_str)
        true
      rescue ArgumentError
        false
      end
    end

    def is_valid_date(id)
      s_digit = id[6...7]

      if "1256".include?(s_digit)
        year_prefix = "19"
      elsif "3478".include?(s_digit)
        year_prefix = "20"
      else
        year_prefix = "18"
      end

      date_str = "#{year_prefix}#{id[0...2]}-#{id[2...4]}-#{id[4...6]}"

      return false unless is_valid_date_str(date_str)

      Date.parse(date_str) < 17.years.ago
    end

    def is_foreigner(id)
      "5678".include?(id[6...7])
    end

    def is_valid_residence_number(input)
      id = input.gsub(/[^\d]/, '')

      is_length_valid(id) &&
      is_check_sum_valid(id) &&
      is_valid_date(id) &&
      !is_foreigner(id)
    end

    def is_valid_amount(input)
      amount = input.gsub(/[^\d]/, '')

      input != "0" &&
      amount.size == input.size &&
      amount.size < 16
    end

    def is_valid_account_number(input)
      account = input.gsub(/[^\d]/, '')

      account.size >= 6 &&
      account.size < 17 &&
      account.size == input.size
    end

    def assert &block
      raise RuntimeError unless yield
    end

    def test_is_valid_residence_number
      # should have 13 numeric chars
      assert { is_valid_residence_number('') == false }
      assert { is_valid_residence_number('800226-123456') == false }
      assert { is_valid_residence_number('800226-12345621') == false }
      assert { is_valid_residence_number('800226-1234562') == true }
      assert { is_valid_residence_number('8002261234562') == true }
      # should have correct check sum.
      assert { is_valid_residence_number('800226-1234562') == true}
      assert { is_valid_residence_number('800226-1234563') == false}
      # should not include foreigner.
      assert { is_valid_residence_number('800226-5234563') == false}
      # should not include too young BOD.
      assert { is_valid_residence_number('031230-3456781') == false}
      assert { is_valid_residence_number('030101-3456780') == true}
    end
    
    def test_is_valid_amount
      # Valid amount for tax input
      # should be less than 16 digits.
      assert { is_valid_amount('100000000000015') == true }
      assert { is_valid_amount('1000000000000016') == false }
      ## 'should be non zero.'
      assert { is_valid_amount('0') == false }
      ## 'should be only a positive number'
      assert { is_valid_amount('1') == true }
      assert { is_valid_amount('-1') == false }
      assert { is_valid_amount('-1.0') == false}
      assert { is_valid_amount('1.0') == false }
    end

    def test_is_valid_account_number
      # Valid account number for tax input
      ## should be less than 17 digits.
      assert { is_valid_account_number('1000000000000016') == true }
      assert { is_valid_account_number('10000000000000017') == false }
      ## should be greater than or equal 6 digits..
      assert { is_valid_account_number('123456') == true }
      assert { is_valid_account_number('12345') == false }
      assert { is_valid_account_number('000001') == true }
      #should be only a positive number
      assert { is_valid_account_number('-1234567') == false }
      assert { is_valid_account_number('123.4567') == false }
      assert { is_valid_account_number('E4567') == false }
    end

    def test
      test_is_valid_residence_number
      test_is_valid_amount
      test_is_valid_account_number
    end
  end
end
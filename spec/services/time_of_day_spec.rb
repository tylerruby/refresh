require 'rails_helper'

RSpec.describe TimeOfDay do
  describe "#to_decimal" do
    it 'is idempotent' do
      expect(TimeOfDay.new(9.5).to_decimal).to eq 9.5
    end

    it 'converts string to decimal' do
      expect(TimeOfDay.new('09:30').to_decimal).to eq 9.5
    end

    it 'converts time to decimal' do
      time = Time.zone.parse('2015-01-01 09:30')
      expect(TimeOfDay.new(time).to_decimal).to eq 9.5
    end
  end

  describe "#to_string" do
    it 'is idempotent' do
      expect(TimeOfDay.new('09:30').to_string).to eq '09:30'
    end

    it 'converts time to string' do
      time = Time.zone.parse('2015-01-01 09:30')
      expect(TimeOfDay.new(time).to_string).to eq '09:30'
    end

    it 'converts decimal to string' do
      expect(TimeOfDay.new(9.5).to_string).to eq '09:30'
    end
  end
end

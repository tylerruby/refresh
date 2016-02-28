require 'rails_helper'

RSpec.describe SelectMenuDates do
  let(:service) { SelectMenuDates.new(today) }

  context "full week, beginning on Monday" do
    let(:today) { Date.parse('2016-01-04') }
    let(:monday) { today }
    let(:tuesday) { monday + 1.day }
    let(:wednesday) { tuesday + 1.day }
    let(:thursday) { wednesday + 1.day }
    let(:friday) { thursday + 1.day }

    it "returns all business days" do
      expect(service.dates).to eq [
        monday,
        tuesday,
        wednesday,
        thursday,
        friday
      ]
    end
  end

  context "weekend in the middle" do
    let(:today) { Date.parse('2016-01-06') }
    let(:wednesday) { today }
    let(:thursday) { wednesday + 1.day }
    let(:friday) { thursday + 1.day }
    let(:monday) { friday + 3.days }
    let(:tuesday) { monday + 1.day }

    it "returns all business days" do
      expect(service.dates).to eq [
        wednesday,
        thursday,
        friday,
        monday,
        tuesday
      ]
    end
  end

  context "holiday in the middle" do
    let(:new_years_day) { Date.parse('2016-01-01') }
    let(:today) { new_years_day }
    let(:friday) { today }
    let(:monday) { friday + 3.days }
    let(:tuesday) { monday + 1.day }
    let(:wednesday) { tuesday + 1.day }
    let(:thursday) { wednesday + 1.day }

    it "returns all business days" do
      expect(service.dates).to eq [
        monday,
        tuesday,
        wednesday,
        thursday
      ]
    end
  end

  context "it already passed the time limit for today" do
    let(:today) { Date.parse('2016-01-04') }
    let(:monday) { today }
    let(:tuesday) { monday + 1.day }
    let(:wednesday) { tuesday + 1.day }
    let(:thursday) { wednesday + 1.day }
    let(:friday) { thursday + 1.day }

    before do
      Timecop.freeze today.in_time_zone.change(hour: 10)
    end

    it "returns all business days" do
      expect(service.dates).to eq [
        tuesday,
        wednesday,
        thursday,
        friday
      ]
    end
  end
end

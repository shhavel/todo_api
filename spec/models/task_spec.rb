require 'rails_helper'

RSpec.describe Task, type: :model do
  context 'validations' do
    subject { build(:task) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
  end
end

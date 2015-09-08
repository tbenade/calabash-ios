describe Calabash::Cucumber::RotationHelpers do

  let(:helper) do
    Class.new do
      include Calabash::Cucumber::RotationHelpers
      include Calabash::Cucumber::EnvironmentHelpers

      def uia_query(_); ; end
      def status_bar_orientation; ; end
      def uia(_); ; end
    end.new
  end


  describe '#rotate' do
    describe 'validates arguments' do
      it 'raises error on invalid arguments' do
        expect do
          helper.rotate(:invalid)
          end.to raise_error ArgumentError, /Expected/
      end

      describe 'valid arguments' do

        before do
          expect(helper).to receive(:ios_version).and_return RunLoop::Version.new('9.0')
          expect(helper).to receive(:status_bar_orientation).and_return(:before, :after)
          expect(helper).to receive(:rotate_with_uia).and_return :orientation
          expect(helper).to receive(:recalibrate_after_rotation).and_call_original
        end

        it 'left' do expect(helper.rotate('left')).to be == :after end
        it ':left' do expect(helper.rotate(:left)).to be == :after end
        it 'right' do expect(helper.rotate('right')).to be == :after end
        it ':right' do expect(helper.rotate(:right)).to be == :after end
      end
    end

    it 'iOS 9' do
      expect(helper).to receive(:ios_version).and_return RunLoop::Version.new('9.0')
      expect(helper).to receive(:status_bar_orientation).and_return(:before, :after)
      expect(helper).to receive(:rotate_with_uia).with(:left, :before).and_return :orientation
      expect(helper).to receive(:recalibrate_after_rotation).and_call_original

      expect(helper.rotate(:left)).to be == :after
    end

    it 'iOS < 9' do
      expect(helper).to receive(:ios_version).and_return RunLoop::Version.new('8.0')
      expect(helper).to receive(:status_bar_orientation).and_return(:before, :after)
      expect(helper).to receive(:rotate_with_playback).with(:left, :before).and_return :orientation
      expect(helper).to receive(:recalibrate_after_rotation).and_call_original

      expect(helper.rotate(:left)).to be == :after
    end
  end

  it '#rotate_with_uia' do
    expect(helper).to receive(:uia_orientation_key).and_return :key
    stub_const('Calabash::Cucumber::RotationHelpers::UIA_DEVICE_ORIENTATION', {:key => 'value' })
    expected = 'UIATarget.localTarget().setDeviceOrientation(value)'
    expect(helper).to receive(:uia).with(expected).and_return :result

    expect(helper.send(:rotate_with_uia, :left, :down)).to be == :result
  end

  describe '#rotate_with_playback' do
    it 'raises error' do
      expect do
        helper.send(:rotate_with_playback, :invalid, :orientation)
      end.to raise_error ArgumentError
    end
  end

  describe '#uia_orientation_key' do
    describe ':left' do
      it ':down' do helper.send(:uia_orientation_key, :left, :down) == :landscape_right end
      it ':right' do helper.send(:uia_orientation_key, :left, :right) == :portrait end
      it ':left' do helper.send(:uia_orientation_key, :left, :left) == :upside_down end
      it ':up' do helper.send(:uia_orientation_key, :left, :up) == :landscape_left end
    end

    describe ':right' do
      it ':down' do helper.send(:uia_orientation_key, :right, :down) == :landscape_left end
      it ':right' do helper.send(:uia_orientation_key, :right, :right) == :upside_down end
      it ':left' do helper.send(:uia_orientation_key, :right, :left) == :portrait end
      it ':up' do helper.send(:uia_orientation_key, :right, :up) == :landscape_right end
    end
  end
end

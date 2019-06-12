RSpec.describe Webview::App do
  let(:root_path) { Webview::ROOT_PATH }
  let(:s_kill) { Signal.list['KILL'] }

  describe '#open/close' do
    it 'should open app window by webview' do
      r = Open3.popen3('sleep 1')
      expect(Open3).to receive(:popen3).with(
        subject.send(:executable) + " -url \"http://localhost:1234/asdf\""
      ).and_return(r)
      expect(subject.open('http://localhost:1234/asdf')).to eql(true)
      sleep 0.5
      ap = subject.app_process

      expect(ap.alive?).to eql(true)
      expect {
        subject.close
        sleep 0.1
      }.to change { ap.alive? }.to(false)
      expect(subject.app_process).to eql(nil)
    end

    it 'should open app window with options' do
      subject = described_class.new(
        width: 100, height: 100, title: "x'xx", resizable: true, debug: true
      )
      r = Open3.popen3('sleep 1')
      expect(Open3).to receive(:popen3).with(
        subject.send(:executable) + " -url \"http://localhost:4321/aaa\"" +
        " -title \"x'xx\" -width \"100\" -height \"100\" -resizable -debug"
      ).and_return(r)
      expect(subject.open('http://localhost:4321/aaa')).to eql(true)
      sleep 0.5
      ap = subject.app_process

      expect(ap.alive?).to eql(true)
      expect {
        subject.close
      }.to change { ap.alive? }.to(false)
      expect(subject.app_process).to eql(nil)
    end

    it 'should not raise error if not found process' do
      subject.open('http://xxx.com')
      subject.signal('KILL')
      subject.close
    end
  end

  it '#join should wait process' do
    subject.open('http://xxx.com')
    expect(Process).to receive(:wait).with(subject.app_process.pid)
    subject.join
    subject.kill
  end

  it '#kill should kill with KILL' do
    subject.open('http://xxx.com')
    expect(Process).to receive(:kill).with(s_kill, subject.app_process.pid).and_call_original
    subject.kill
  end

  it '#kill should raise error if process was killed' do
    subject.open('http://xxx.com')
    subject.signal('KILL')
    expect(Process).to receive(:kill).with(s_kill, subject.app_process.pid).and_call_original
    subject.kill
  end

  it '#signal should not raise error if process not found' do
    subject.open('http://xxx.com')
    expect(Process).to receive(:kill) \
      .with(Signal.list['EXIT'], subject.app_process.pid).and_call_original.twice
    expect(Process).to receive(:kill) \
      .with(s_kill, subject.app_process.pid).and_call_original.twice
    subject.signal("QUIT")
    subject.signal("QUIT")
    subject.signal("KILL")
    subject.signal("KILL")
  end

  it '#executable should return path of webview binary' do
    expect(subject).to receive(:executable).and_call_original
    expect(subject.send(:executable)).to eql(File.join(Webview::ROOT_PATH, 'ext/webview_app'))
  end

  it 'executable should able to run' do
    _out, help, _ = Open3.capture3("#{subject.send(:executable)} -h")
    keys = help.lines.select { |l| l =~ /\s*-\w+\s/ }.map(&:strip).map { |s| s.split.first }
    expect(help).to match(/^Usage of /)
    expect(keys.sort).to eql(%w{-debug -height -resizable -title -url -width})
  end
end

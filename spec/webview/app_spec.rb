RSpec.describe Webview::App do
  let(:root_path) { Webview::ROOT_PATH }

  describe '#open/close' do
    it 'should open app window by webview' do
      expect(subject).to receive(:exec_cmd).with(
        File.join(root_path, 'ext/webview_app') + " -url 'http://localhost:1234/asdf'"
      ).and_call_original
      expect(subject.open('http://localhost:1234/asdf')).to eql(true)
      sleep 0.5
      ap = subject.app_process
      expect(ap.alive?).to eql(true) if $gui_env
      expect {
        subject.close
      }.to change { ap.alive? }.to(false)
      expect(subject.app_process).to eql(nil)
    end

    it 'should open app window with options' do
      subject = described_class.new(
        width: 100, height: 100, title: 'x"xx', resizable: true, debug: true
      )
      expect(subject).to receive(:exec_cmd).with(
        File.join(root_path, 'ext/webview_app') + " -url 'http://localhost:4321/aaa'" +
        " -title 'x\"xx' -width '100' -height '100' -resizable -debug"
      ).and_call_original
      expect(subject.open('http://localhost:4321/aaa')).to eql(true)
      sleep 0.5
      ap = subject.app_process
      expect(ap.alive?).to eql(true) if $gui_env
      expect {
        subject.close
      }.to change { ap.alive? }.to(false)
      expect(subject.app_process).to eql(nil)
    end

    it 'should not raise error if not found process' do
      subject.open('http://xxx.com')
      subject.signal('TERM')
      subject.close
    end
  end

  it '#join should wait process' do
    subject.open('http://xxx.com')
    expect(Process).to receive(:wait).with(subject.app_process.pid)
    subject.join
    subject.kill
  end

  it '#kill should kill with TERM' do
    subject.open('http://xxx.com')
    expect(Process).to receive(:kill).with('TERM', subject.app_process.pid).and_call_original
    subject.kill
  end

  it '#kill should raise error if process was killed' do
    subject.open('http://xxx.com')
    subject.signal('TERM')
    expect(Process).to receive(:kill).with('TERM', subject.app_process.pid).and_call_original
    subject.kill
  end

  it '#signal should not raise error if process not found' do
    subject.open('http://xxx.com')
    expect(Process).to receive(:kill).with('QUIT', subject.app_process.pid).and_call_original.twice
    expect(Process).to receive(:kill).with('TERM', subject.app_process.pid).and_call_original.twice
    subject.signal("QUIT")
    subject.signal("QUIT")
    subject.signal("TERM")
    subject.signal("TERM")
  end
end

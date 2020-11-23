describe port(80) do
  it { should be_listening }
end

describe port(8080) do
  it { should_not be_listening }
end

describe package('nginx') do
  it { should be_installed }
end


describe os.family do
  it { should eq 'debian' }
end

describe http('http://127.0.0.1:80') do
  its('body') { should include 'EHLO world !' }
end

describe ssh_config do
  its('port') { should eq '22' }
end

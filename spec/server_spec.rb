require 'spec_helper'
RSpec::Expectations.configuration.on_potential_false_positives = :nothing

describe Server do
    context 'configuration' do
        it 'can be passed via initialization' do
            expect {
                server = Server.new({
                    username: ENV['TSS_USERNAME'].to_s,
                    password: ENV['TSS_PASSWORD'],
                    tenant: ENV['TSS_TENANT']
                })
            }.not_to raise_error(ArgumentError)
        end
    end

    before(:each) do
        @server = Server.new({
            username: ENV['TSS_USERNAME'],
            password: ENV['TSS_PASSWORD'],
            tenant: ENV['TSS_TENANT']
        })
    end
    context 'accessResource' do
        it 'only permits "GET", "POST", "PUT", "DELETE" methods' do
            expect { @server.accessResource("test", "secrets", "", "") }.to raise_error(InvalidMethodTypeException)
        end

        it 'only permits access to the "secrets" resource' do
            expect { @server.accessResource("GET", "test", "", "") }.to raise_error(UnrecognizedResourceException)
        end

        it 'requires valid credentials' do
            @server = Server.new({
                username: 'fakeusername',
                password: ENV['TSS_PASSWORD'],
                tenant: ENV['TSS_TENANT']
            })
            expect { @server.accessResource("GET", "secrets", "", "") }.to raise_error(InvalidCredentialsException)
        end
    end
end

# todo: These tests are too volatile. Shift to mocks
describe Server::Secret do
    before(:each) do
        @server = Server.new({
            username: ENV['TSS_USERNAME'],
            password: ENV['TSS_PASSWORD'],
            tenant: ENV['TSS_TENANT']
        })
    end

    context 'fetch' do
        it 'requires a Server and an id' do
            expect { Server::Secret.fetch() }.to raise_error(ArgumentError)
            expect { Server::Secret.fetch(@server) }.to raise_error(ArgumentError)
            expect { Server::Secret.fetch(@server, 1) }.not_to raise_error(ArgumentError)
        end

        it 'returns a hash of the secret' do
            s = Server::Secret.fetch(@server, 1)
            expect(s).to be_a(Hash)

            expect(s['name']).to eq("Test Secret")
            expect(s['items']).to be_a(Array)
            expect(s['items'][0]).to be_a(Hash)
        end

        it 'raises InvalidSecretException if secret is not found' do
            expect { Server::Secret.fetch(@server, 999)}.to raise_error(InvalidSecretException)
        end

    end
end

#ifndef LIB_RULES_SERVERMESSENGER_HH_
# define LIB_RULES_SERVERMESSENGER_HH_

# include <memory>
# include <stdexcept>

# include <rules/messenger.hh>
# include <net/server-socket.hh>
# include <utils/buffer.hh>

namespace rules {

class Actions;

class ServerMessengerError : public std::runtime_error
{
public:
    ServerMessengerError() : std::runtime_error("Server messenger error") {}
};

class ServerMessenger : public Messenger
{
public:
    explicit ServerMessenger(net::ServerSocket_sptr sckt);

    void send(const utils::Buffer&) override;

    utils::Buffer* recv() override;
    void recv_actions(Actions* actions);

    bool poll(long timeout);

    void push(const utils::Buffer&);
    void push_actions(Actions& actions);
    void push_id(uint32_t id);

    void ack();
    void wait_for_ack();

    uint32_t last_client_id()
        { return last_client_id_; }

private:
    net::ServerSocket_sptr sckt_;
    uint32_t last_client_id_;
};

typedef std::shared_ptr<ServerMessenger> ServerMessenger_sptr;

} // namespace rules

#endif // !LIB_RULES_SERVERMESSENGER_HH_

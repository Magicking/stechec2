#ifndef LIB_RULES_CLIENTMESSENGER_HH_
# define LIB_RULES_CLIENTMESSENGER_HH_

# include <memory>
# include <stdexcept>

# include <rules/messenger.hh>
# include <net/client-socket.hh>
# include <utils/buffer.hh>

namespace rules {

// Forward decls
class Actions;

class ClientMessengerError : public std::runtime_error
{
public:
    ClientMessengerError() : std::runtime_error("Client messenger error") {}
};

class ClientMessenger : public Messenger
{
public:
    ClientMessenger(net::ClientSocket_sptr sckt, uint32_t client_id);

    void send(const utils::Buffer&) override;
    void send_actions(Actions&);

    utils::Buffer* recv() override;

    utils::Buffer* pull();
    void pull_actions(Actions*);
    void pull_id(uint32_t*);

    void ack();
    void wait_for_ack();

    /* Wait until a new turn. Put the ID of the correspondin player into
     * `pulled_id` and return if this is the same as `player_id`. */
    bool wait_for_turn(uint32_t player_id, uint32_t* pulled_id);

private:
    net::ClientSocket_sptr sckt_;
    uint32_t client_id_;
};

typedef std::shared_ptr<ClientMessenger> ClientMessenger_sptr;

} // namespace rules

#endif // !LIB_RULES_CLIENTMESSENGER_HH_

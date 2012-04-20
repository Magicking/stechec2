#ifndef RULES_RULES_HH_
# define RULES_RULES_HH_

# include <utils/dll.hh>

class Rules
{
public:
    explicit Rules(const std::string& champion);
    virtual ~Rules();

private:
    Utils::DLL* champion_dll_;
};

#endif // !RULES_RULES_HH_

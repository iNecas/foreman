module Actions

  class DomainCreate < Dynflow::Action

    def plan(domain)
      domain.save!
      plan_self id: domain.id, name: domain.name, fullname: domain.fullname
    end

    input_format do
      params :id
      params :name
      params :fullname
    end

  end
end

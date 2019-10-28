module DeleteResourceRoute
  def resources(*args)
    super(*args) do
      yield if block_given?
      if args.length == 1
        member do
          get :delete
          delete :delete, action: :destroy
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.include DeleteResourceRoute

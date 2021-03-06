require 'active_support/concern'
require 'open-uri'
module VimBundler
  module VimOrg
    extend ActiveSupport::Concern
    module Installer
      extend ActiveSupport::Concern
      module InstanceMethods
        include VimBundler::Actions
        def vim_org_install(bundle)
          dir = File.join(@opts[:bundles_dir], bundle.name)
          if Dir.exists?(dir)
            VimBundler.ui.info "#{bundle.name} already installed" 
            return
          end
          FileUtils.mkdir_p(dir)
          f = open("http://www.vim.org/scripts/download_script.php?src_id=#{bundle.vim_script_id}")
          local_file = f.meta["content-disposition"].gsub(/attachment; filename=/,"")
          if local_file.end_with? 'vim'
            as = bundle.respond_to?(:as) ? bundle.as.to_s : 'plugin'
            FileUtils.mkdir_p(File.join(dir, as))
            data = open(File.join(dir, as, local_file), 'w')
            data.write f.read
          end
          VimBundler.ui.info "#{bundle.name} installed"
        end
        def vim_org_update(bundle)
          clean(bundle)
          vim_org_install(bundle)
        end
        def vim_org_clean(bundle)
          clean(bundle)
        end
      end
    end
    module DSL
      extend ActiveSupport::Concern
      included do
        handler :vim_org do |bundle|
          bundle.respond_to?(:vim_script_id)
        end
      end
    end
    included do
      VimBundler::Installer.send(:include, VimBundler::VimOrg::Installer)
      VimBundler::DSL.send(:include, VimBundler::VimOrg::DSL)
    end
  end
end

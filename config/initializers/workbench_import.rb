WorkbenchImportWorker.config do | config |
  config.dir = SmartEnv.fetch('WORKBENCH_IMPORT_DIR'){ Rails.root.join 'tmp/workbench_import' }

  FileUtils.mkdir_p config.dir
end

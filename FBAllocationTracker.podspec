Pod::Spec.new do |s|
  s.name         = "FBAllocationTracker"
  s.version      = "0.1.5"
  s.summary      = "Interface for tracking allocations and generations of objects"
  s.homepage     = "https://github.com/facebook/FBAllocationTracker"
  s.license      = "BSD"
  s.author       = { "Grzegorz Pstrucha" => "gricha@fb.com" }
  s.platform     = :ios, "7.0"
  s.source       = {
    :git => "https://github.com/facebook/FBAllocationTracker.git",
    :tag => "0.1.5"
  }
  s.source_files  = "FBAllocationTracker", "FBAllocationTracker/**/*.{h,m,mm}"

  mrr_files = [
    'FBAllocationTracker/NSObject+FBAllocationTracker.h',
    'FBAllocationTracker/NSObject+FBAllocationTracker.mm',
    'FBAllocationTracker/Generations/FBAllocationTrackerNSZombieSupport.h',
    'FBAllocationTracker/Generations/FBAllocationTrackerNSZombieSupport.mm'
  ]

  files = Pathname.glob("FBAllocationTracker/**/*.{h,m,mm}")
  files = files.map {|file| file.to_path}
  files = files.reject {|file| mrr_files.include?(file)}

  s.requires_arc = files
  s.public_header_files = [
    'FBAllocationTracker/FBAllocationTracker.h',
    'FBAllocationTracker/FBAllocationTrackerManager.h',
    'FBAllocationTracker/FBAllocationTrackerSummary.h',
    'FBAllocationTracker/FBAllocationTrackerDefines.h',
  ]

  s.framework = "Foundation"
  s.library = 'c++'
end

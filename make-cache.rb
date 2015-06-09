#!/usr/bin/env ruby

#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

require "digest"
require "net/http"

cache_dir = File.expand_path("../cache", __FILE__)

cache = [
  {
    checksum: "251743dfd3fda414570524bac9e55381",
    details:  "https://www.microsoft.com/en-gb/download/details.aspx?id=17718",
    filename: "dotNetFx40_Full_x86_x64.exe",
    name:     ".NET Framework 4 (Standalone Installer)",
    url:      "http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe",
  },
  {
    checksum: "f0796f7930f4a4337e674d38bc2a6d98",
    details:  "http://windows.php.net/download/",
    filename: "php-5.5.24-nts-vc11-x86.zip",
    name:     "PHP 5.5.24 NTS VC11 x86 build",
    url:      "http://windows.php.net/downloads/releases/php-5.5.24-nts-Win32-VC11-x86.zip",
  },
  {
    checksum: "3b3fb0d8eb3d45a2a20097da614a9efc",
    details:  "https://phpmanager.codeplex.com/releases/view/69115",
    filename: "PHPManagerForIIS-1.2.0-x64.msi",
    name:     "PHP Manager for IIS (this will fail because Microsoft hate you)",
    url:      "http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=phpmanager&DownloadId=253209&FileTime=129536821813970000&Build=20988",
  },
  {
    checksum: "79c2741d3e363c39cf0635bbe003e699",
    details:  "http://www.microsoft.com/en-gb/download/details.aspx?id=30438",
    filename: "SQLEXPRADV_x64_ENU.exe",
    name:     "SQL Server 2008 R2 SP2 - Express Edition",
    url:      "http://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPRADV_x64_ENU.exe",
  },
  {
    checksum: "f23ae6f6e02b97e4914cbd044411c054",
    details:  "https://www.microsoft.com/en-gb/download/details.aspx?id=34595",
    filename: "Windows6.1-KB2506143-x64.msu",
    name:     "Windows Management Framework 3.0",
    url:      "http://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu",
  },
  {
    checksum: "c787d79b2d1a7b732ba325873e916f73",
    details:  "http://www.microsoft.com/en-gb/download/confirmation.aspx?id=7435",
    filename: "rewrite_2.0_rtw_x64.msi",
    name:     "URL Rewrite Module 2.0 for IIS 7 (x64)",
    url:      "http://download.microsoft.com/download/6/7/D/67D80164-7DD0-48AF-86E3-DE7A182D6815/rewrite_2.0_rtw_x64.msi",
  },
]

download = []

cache.each do |file_info|
  puts "Checking #{file_info[:name]}..."

  filename = File.join cache_dir, file_info[:filename]

  if !File.file? filename
    puts "\tFile #{file_info[:filename]} doesn't exist"
    download << file_info
    next
  end

  checksum = Digest::MD5.file(filename).hexdigest
  if checksum != file_info[:checksum]
    puts "\tChecksum #{checksum} doesn't match expected #{file_info[:checksum]}"
    download << file_info
    next
  end

  puts "\tAlready cached"
end

puts "Downloading #{download.size} files..."

download.each do |file_info|
  puts "\tDownloading #{file_info[:url]} to #{file_info[:filename]}"
  filename = File.join cache_dir, file_info[:filename]
  file     = File.open filename, 'w+'

  uri = URI.parse file_info[:url]
  Net::HTTP.start uri.host, uri.port do |http|
    begin
      http.request_get(uri.path) do |response|
        response.read_body {|segment| file.write segment}
      end
    ensure
      file.close
    end
  end
end

puts "\tDone"

#encoding: UTF-8

require 'spec_helper'
require 'helper/account'
require 'ruby-box'
require 'webmock/rspec'

describe RubyBox::Folder do
  before do
    @session = RubyBox::Session.new
    @full_folder = JSON.parse('{    "type": "folder",    "id": "11446498",    "sequence_id": "1",    "etag": "1",    "name": "Pictures",    "created_at": "2012-12-12T10:53:43-08:00",    "modified_at": "2012-12-12T11:15:04-08:00",    "description": "Some pictures I took",    "size": 629644,    "path_collection": {        "total_count": 1,        "entries": [            {                "type": "folder",                "id": "0",                "sequence_id": null,                "etag": null,                "name": "All Files"            }        ]    },    "created_by": {        "type": "user",        "id": "17738362",        "name": "sean rose",        "login": "sean@box.com"    },    "modified_by": {        "type": "user",        "id": "17738362",        "name": "sean rose",        "login": "sean@box.com"    },    "owned_by": {        "type": "user",        "id": "17738362",        "name": "sean rose",        "login": "sean@box.com"    },    "shared_link": {        "url": "https://www.box.com/s/vspke7y05sb214wjokpk",        "download_url": "https://www.box.com/shared/static/vspke7y05sb214wjokpk",        "vanity_url": null,        "is_password_enabled": false,        "unshared_at": null,        "download_count": 0,        "preview_count": 0,        "access": "open",        "permissions": {            "can_download": true,            "can_preview": true        }    },    "folder_upload_email": {        "access": "open",        "email": "upload.Picture.k13sdz1@u.box.com"    },    "parent": {        "type": "folder",        "id": "0",        "sequence_id": null,        "etag": null,        "name": "All Files"    },    "item_status": "active",    "item_collection": {        "total_count": 1,        "entries": [            {                "type": "file",                "id": "5000948880",                "sequence_id": "3",                "etag": "3",                "sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc",                "name": "tigers.jpeg"            }        ],        "offset": 0,        "limit": 100    }}')
    @mini_folder = JSON.parse('{    "type":"folder",    "id":"301415432",    "sequence_id":"0",    "name":"my first sub-folder"}')
    @items = [
      JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047867",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s your folder"        },        {            "type": "file",            "id": "409042867",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        },    { "type": "collaboration", "id": "409042000", "status": "accepted" } ],    "offset": "0",    "limit": "3"}'),
      JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047868",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s another folder"        },        {            "type": "file",            "id": "409042810",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        },    { "type": "collaboration", "id": "409042001", "status": "accepted" }   ],    "offset": "2",    "limit": "3"}')
    ]
  end

  it "#root returns full root folder object" do
    session = RubyBox::Session.new
    expect(session).to receive(:request).once.and_return(@full_folder)
    root = RubyBox::Client.new(session).root_folder
    expect(root.name).to eq('Pictures')
  end

  it "returns iso8601 format keys as a time object" do
    session = RubyBox::Session.new
    expect(session).to receive(:request).once.and_return(@full_folder)
    root = RubyBox::Client.new(session).root_folder
    expect(root.created_at.year).to eq(2012)
  end

  describe "#find_by_type" do
    it "compares name in a case insensitive manner" do
      items = [
        JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047867",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s your folder"        },        {            "type": "file",            "id": "409042867",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }    ],    "offset": "0",    "limit": "2"}'),
        JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047868",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s another folder"        },        {            "type": "file",            "id": "409042810",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }    ],    "offset": "2",    "limit": "2"}')
      ]

      session = RubyBox::Session.new
      allow(session).to receive(:request) { items.pop }

      # should return one file.
      files = RubyBox::Folder.new(session, {'id' => 1}).files('A CHOICE file')
      expect(files.count).to eq(1)
    end
  end

  describe '#items' do
    it "should return a folder object for folder items" do
      item = JSON.parse('{    "id": "0000001", "total_count": 1,    "entries": [        {            "type": "folder",            "id": "409047867",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s your folder"        }   ],    "offset": "0",    "limit": "1"}')
      session = RubyBox::Session.new
      expect(session).to receive(:request).and_return(item)
      item = RubyBox::Client.new(session).root_folder.items.first
      expect(item.kind_of?(RubyBox::Folder)).to be_truthy
    end

    it "should return a file object for file items" do
      item = JSON.parse('{    "id": "0000001", "total_count": 1,    "entries": [ {            "type": "file",            "id": "409042867",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }   ],    "offset": "0",    "limit": "1"}')
      session = RubyBox::Session.new
      expect(session).to receive(:request).and_return(item)
      item = RubyBox::Client.new(session).root_folder.items.first
      expect(item.kind_of?(RubyBox::File)).to be_truthy
    end

    it "it should return an iterator that lazy loads all entries" do
      session = RubyBox::Session.new
      allow(session).to receive(:request) { @items.pop }
      items = RubyBox::Folder.new(session, {'id' => 1}).items(1).to_a
      expect(items[0].kind_of?(RubyBox::Folder)).to eq(true)
      expect(items[1].kind_of?(RubyBox::File)).to eq(true)
    end

    it "should allow a fields parameter to be set" do
      session = RubyBox::Session.new
      expect(session).to receive(:get).with('https://api.box.com/2.0/folders/1/items?limit=100&offset=0&fields=size').and_return({'entries' => []})
      RubyBox::Folder.new(session, {'id' => 1}).items(100, 0, [:size]).to_a
    end

    it "should not have the fields parameter set by default" do
      session = RubyBox::Session.new
      expect(session).to receive(:get).with('https://api.box.com/2.0/folders/1/items?limit=100&offset=0').and_return({'entries' => []})
      RubyBox::Folder.new(session, {'id' => 1}).items.to_a
    end
  end

  describe '#files' do
    it "should only return items of type file" do
      session = RubyBox::Session.new
      allow(session).to receive(:request) { @items.pop }
      files = RubyBox::Folder.new(session, {'id' => 1}).files
      expect(files.count).to eq(1)
      expect(files.first.kind_of?(RubyBox::File)).to eq(true)
    end

    it "should allow you to filter files by name" do
      items = [
        JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047867",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s your folder"        },        {            "type": "file",            "id": "409042867",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }    ],    "offset": "0",    "limit": "2"}'),
        JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047868",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s another folder"        },        {            "type": "file",            "id": "409042810",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }    ],    "offset": "2",    "limit": "2"}')
      ]

      session = RubyBox::Session.new
      allow(session).to receive(:request) { items.pop }

      # should return one file.
      files = RubyBox::Folder.new(session, {'id' => 1}).files('A choice file')
      expect(files.count).to eq(1)

      items = [
        JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047867",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s your folder"        },        {            "type": "file",            "id": "409042867",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }    ],    "offset": "0",    "limit": "2"}'),
        JSON.parse('{    "total_count": 4,    "entries": [        {            "type": "folder",            "id": "409047868",            "sequence_id": "1",            "etag": "1",            "name": "Here\'s another folder"        },        {            "type": "file",            "id": "409042810",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }    ],    "offset": "2",    "limit": "2"}')
      ]

      # should return no files.
      files = RubyBox::Folder.new(session, {'id' => 1}).files('foobar')
      expect(files.count).to eq(0)
    end
  end

  describe '#discussions' do
    it "should return all the discussions surrounding a folder" do
      item = JSON.parse('{    "id": "0000001", "total_count": 1,    "entries": [ {            "type": "discussion",            "id": "409042867",            "sequence_id": "1",            "etag": "1",            "name": "A choice file"        }   ],    "offset": "0",    "limit": "1"}')
      session = RubyBox::Session.new
      allow(session).to receive(:request).and_return(item)
      item = RubyBox::Client.new(session).root_folder.discussions.first
      expect(item.kind_of?(RubyBox::Discussion)).to eq(true)
    end
  end

  describe '#folders' do
    it "should only return items of type folder" do
      session = RubyBox::Session.new
      allow(session).to receive(:request) { @items.pop }
      files = RubyBox::Folder.new(session, {'id' => 1}).folders
      expect(files.count).to eq(1)
      expect(files.first.kind_of?(RubyBox::Folder)).to eq(true)
    end
  end

  context '#copy_to' do
    let(:source_folder) { RubyBox::Folder.new(@session, {'id' => 1}) }
    let(:destination) { RubyBox::Folder.new(@session, {'id' => 100}) }

    it 'uses itself for the copy uri' do
      expect(@session).to receive(:request) do |uri, _|
        expect(uri.to_s).to match(/folders\/#{source_folder.id}\/copy/)
      end
      source_folder.copy_to destination
    end

    it 'uses the destination as the parent' do
      expect(@session).to receive(:request) do |_, response|
        expect(JSON.parse(response.body)['parent']['id']).to eq(destination.id)
      end
      source_folder.copy_to destination
    end

    it 'uses the source as the name by default' do
      expect(@session).to receive(:request) do |_, response|
        expect(JSON.parse(response.body)).not_to have_key('name')
      end
      source_folder.copy_to destination
    end

    it 'can provide a new name if desired' do
      expect(@session).to receive(:request) do |_, response|
        expect(JSON.parse(response.body)['name']).to eq('renamed-folder')
      end
      source_folder.copy_to destination, 'renamed-folder'
    end

    it 'returns the newly created folder' do
      expect(@session).to receive(:request).and_return('type' => 'folder', 'id' => '123')
      copied_folder = source_folder.copy_to(destination)

      expect(copied_folder).to be_a(RubyBox::Folder)
      expect(copied_folder.id).to eq("123")
    end
  end

end

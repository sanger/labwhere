require 'rails_helper'

describe SoftDeletable do

  with_model :BlogPost do

    table do |t|
      t.string :title
      t.timestamps null: false
      t.datetime :deleted_at
    end

    model do
      include SoftDeletable
    end
    
  end

  before(:each) do
    4.times { |n| BlogPost.create(title: "A blog post")}
  end

  it "#destroy should do a soft delete" do
    BlogPost.first.destroy
    expect(BlogPost.with_deleted.size).to eq(4)
    expect(BlogPost.without_deleted.size).to eq(3)
    expect(BlogPost.deleted.size).to eq(1)
  end

  it "#destroy with a hard delete should delete record" do
    BlogPost.first.destroy(:hard)
    expect(BlogPost.with_deleted.size).to eq(3)
    expect(BlogPost.without_deleted.size).to eq(3)
    expect(BlogPost.deleted).to be_empty
  end

  it "#restore should restore a soft deleted record" do
    BlogPost.first.destroy
    expect(BlogPost.first.deleted?).to be_truthy
    BlogPost.first.restore
    expect(BlogPost.first.deleted?).to be_falsey
  end
  
end
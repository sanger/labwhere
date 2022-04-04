# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoftDeletable, type: :model do
  with_model :BlogPost do
    table do |t|
      t.string :title
      t.timestamps null: false
    end
  end

  with_model :Comment do
    table do |t|
      t.string :text
      t.belongs_to :blog_post
      t.timestamps null: false
      t.datetime :deleted_at
    end

    model do
      belongs_to :blog_post, optional: true

      include SoftDeletable
      removable_associations :blog_post
    end
  end

  with_model :TestModel do
    table do |t|
      t.string :text
      t.timestamps null: false
      t.datetime :deleted_at
    end

    model do
      include SoftDeletable
    end
  end

  before(:each) do
    4.times { |_n| TestModel.create(text: "A comment") }
  end

  it "#destroy should do a soft delete" do
    TestModel.first.destroy
    expect(TestModel.with_deleted.size).to eq(4)
    expect(TestModel.without_deleted.size).to eq(3)
    expect(TestModel.deleted.size).to eq(1)
  end

  it "#destroy with a hard delete should delete record" do
    TestModel.first.destroy(:hard)
    expect(TestModel.with_deleted.size).to eq(3)
    expect(TestModel.without_deleted.size).to eq(3)
    expect(TestModel.deleted).to be_empty
  end

  it "#restore should restore a soft deleted record" do
    TestModel.first.destroy
    expect(TestModel.first.deleted?).to be_truthy
    TestModel.first.restore
    expect(TestModel.first.deleted?).to be_falsey
  end

  it "#destroy should remove any associations specified" do
    blog_post = BlogPost.create(title: "A blog post")
    comment = Comment.create(text: "A Comment")
    comment.update(blog_post: blog_post)
    comment.destroy
    expect(comment.reload.blog_post).to be_nil
  end
end

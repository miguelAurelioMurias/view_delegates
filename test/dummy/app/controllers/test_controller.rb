class TestController < ApplicationController
  def index
    @delegate = BasicDelegate.new
  end
end

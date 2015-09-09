# ruby-ml
A small and straight forward machine learning program in ruby

Salut

# Why

In my job, we needed to categorize crawled job offers descriptions in their associated positions.
After a lot of thinking, I came with the idea that machine learning would be great solution to handle this kind of problem.
My hierarchie was really perplex about it, and told me that I needed to have a real plan to develop it.

After some years of C development, and just 2 or 3 months of experience in Ruby, I felt like I was more capable of
developing a machine learning in Ruby, because it was so much simpler and clearer to me, not caring about real-time performance.

My network was all like, you need to think about scalability, you can't just make a machine learning in ruby blabla, you need to do it in
/.*/ technology but no ruby.

In the train back home, with my mac, i just tried it, and it was so clear in my mind, that I just finished it in 2 or 3 days for a demo to my boss.

After that, it was only testing, adjusting and stuff, and it was after 3 months in production, and we still use it for many categorizing.


After a lot of encouragment, and a talk about it at the Paris.rb meetup, I decided to put it in opensource.

This is just my first version, without tweaking.

Feel free to contribute

# How to make it work
This machine learning is programmed to categorize an article to its feeling.
Either positive, negative, or any feeling you can imagine.

# The code
You need postgresql
once installed, setup your database:
```
  42sh$ rake db:create
  42sh$ rake db:migrate
```
After that, you need to add your data, what the machine will learn. Here it was more conveniant for us to add one json file by article.
They are in the folder
```
  data/kernel/feeling/*.json
```
each file is a json with the params title, description, and feeling.
Once your data is here, you extract the keywords doing
```
  42sh$ ruby console
  pry> Mapper::EngineParameter.new('feeling').generate_new_keyword_set_from_kernel
  pushed on file data/engine_parameters/feeling.keys
  => true
```
Congratz !
You can now schedule it like every time you add data (we have a scheduler that do it on a daily basis)
Now you can map your article regarding your data.

```
  42sh$ ruby console
  pry> article = Article.create(title: 'negatif', description: 'je suis positif')
  pry> Mapper::Processor.new.run(article)
  #<Article:0x00xxxxx id: 1, title: "negatif", description: "je suis positif", feeling: "positif", ...>
```
Yay! your article has been mapped to its feeling

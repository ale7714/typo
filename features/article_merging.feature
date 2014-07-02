Feature: Merge Articles
  As a blog administrator
  In order to combine articles about similar topics
  I want to be able to merge articles in my blog

  Background:
    Given the blog is set up
    And some users, articles and comments has been created

  Scenario: A non-admin cannot merge articles
        Given I am logged in as "non_admin" with password "123user"
        And I am on the edit page of an article with id 1
        Then I should not see "Merge Articles"

  Scenario: An admin can merge articles
        Given I am logged in as "admin" with password "aaaaaaaa"
        And I am on the edit page of an article with id 3
        Then I should see "Merge Articles"
        When I fill in "merge_with" with "4"
        And I press "Merge"
        Then I should be on the admin content page
        And I should see "Articles successfully merged."

 Scenario: The merged article should contain the text of both previous articles
        Given I am logged in as "admin" with password "aaaaaaaa"
        And I merged articles with id "3" and "4"
        And I am on the edit page of an article with id 3
        Then I should see "A very fun first article"
        Then I should see "A very fun second article, hum?"

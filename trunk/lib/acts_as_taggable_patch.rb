# A patch that work on PostgreSQL
# acts_as_taggable 1.0.4
# find_tagged_with : http://rubyforge.org/tracker/index.php?func=detail&aid=2482&group_id=923&atid=3629
# tags_count       : original
if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  module ActiveRecord
    module Acts
      module Taggable
        module SingletonMethods
          def find_tagged_with(options = {}) 
            options = { :separator => ' ' }.merge(options)

            tag_names = ActiveRecord::Acts::Taggable.split_tag_names(options[:any] || options[:all], options[:separator])
            raise "No tags were passed to :any or :all options" if tag_names.empty?

            o, o_pk, o_fk, t, t_pk, t_fk, jt = set_locals_for_sql
            sql = "SELECT #{o}.* FROM #{o} WHERE #{o}.#{o_pk} IN (
                  SELECT #{jt}.#{o_fk} FROM #{jt}, #{t} WHERE #{jt}.#{t_fk} = #{t}.#{t_pk}
                  AND (#{t}.name = '#{tag_names.join("' OR #{t}.name='")}')
                  GROUP BY #{jt}.#{o_fk}"
            sql << " HAVING COUNT(#{jt}.#{o_fk}) = #{tag_names.length}" if options[:all]
            sql << " )"
            sql << " AND #{sanitize_sql(options[:conditions])}" if options[:conditions]
            sql << " ORDER BY #{options[:order]} " if options[:order]
            add_limit!(sql, options)

            find_by_sql(sql)
          end

          def tags_count(options = {})
            options = {:order => 'count DESC'}.merge(options)

            o, o_pk, o_fk, t, t_pk, t_fk, jt = set_locals_for_sql
            sql = "SELECT #{t}.#{t_pk} AS id, #{t}.name AS name, tc.count AS count 
                  FROM #{t}, (
                   SELECT #{jt}.#{t_fk} AS id, COUNT(*) AS count FROM #{jt} GROUP BY #{jt}.#{t_fk}
                  ) AS tc 
                  WHERE #{t}.#{t_pk} = tc.id "
            sql << " AND count #{options[:count]} " if options[:count]
            sql << " AND #{sanitize_sql(options[:conditions])} " if options[:conditions]
            sql << " ORDER BY #{options[:order]} " if options[:order]
            add_limit!(sql, options)
            result = connection.select_all(sql)
            count = result.inject({}) { |hsh, row| hsh[row['name']] = row['count'].to_i; hsh } unless options[:raw]

            count || result
          end

          def find_related_tagged(related, options = {})
            related_id = related.is_a?(self) ? related.id : related
            options = { :limit => 5 }.merge(options)

            o, o_pk, o_fk, t, t_pk, t_fk, jt = set_locals_for_sql
            sql = "SELECT #{o}.*, c.count AS count FROM #{o}, 
                    (SELECT #{o_fk}, COUNT(#{o_fk}) AS count FROM #{jt} 
                     WHERE #{o_fk} != #{related_id} 
                      AND #{t_fk} IN (SELECT #{t_fk} FROM #{jt} WHERE #{o_fk} = #{related_id}) 
                     GROUP BY #{o_fk} 
                    ) AS c 
                    WHERE #{o}.id = c.#{o_fk} 
                    ORDER BY c.count DESC"
            add_limit!(sql, options)

            find_by_sql(sql)
          end

          def find_related_tags(tags, options = {})                
            tag_names = ActiveRecord::Acts::Taggable.split_tag_names(tags, options[:separator])
            o, o_pk, o_fk, t, t_pk, t_fk, jt = set_locals_for_sql

            sql = "SELECT jt.#{o_fk} AS o_id FROM #{jt} jt, #{t} t 
                   WHERE jt.#{t_fk} = t.#{t_pk} 
                   AND (t.name IN ('#{tag_names.uniq.join("', '")}')) 
                   GROUP BY jt.#{o_fk} 
                   HAVING COUNT(jt.#{o_fk})=#{tag_names.length}"

            o_ids = connection.select_all(sql).map { |row| row['o_id'] }
            return options[:raw] ? [] : {} if o_ids.length < 1

            sql = "SELECT t.#{t_pk} AS id, t.name AS name, COUNT(jt.#{o_fk}) AS count FROM #{jt} jt, #{t} t 
                   WHERE jt.#{o_fk} IN (#{o_ids.join(",")}) 
                   AND t.#{t_pk} = jt.#{t_fk}
                   GROUP BY jt.#{t_fk}, t.#{t_pk}, t.name
                   ORDER BY count DESC"
            add_limit!(sql, options)

            result = connection.select_all(sql).delete_if { |row| tag_names.include?(row['name']) }
            count = result.inject({}) { |hsh, row| hsh[row['name']] = row['count'].to_i; hsh } unless options[:raw]

            count || result
          end
        end
      end
    end
  end
end

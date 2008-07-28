module DBI
    module Utils
        module TableFormatter

            # FIXME this is probably short-sighted.
            def self.coerce(obj)
                obj = "NULL" if obj.nil?
                obj = (obj.kind_of?(Array) or obj.kind_of?(Hash)) ? obj.inspect : obj.to_s
                return obj
            end

            # TODO: add a nr-column where the number of the column is shown
            def self.ascii(header, 
                           rows, 
                           header_orient=:left, 
                           rows_orient=:left, 
                           indent=2, 
                           cellspace=1, 
                           pagebreak_after=nil,
                           output=STDOUT)

                if rows.size == 0 or rows[0].size == 0
                    output.puts "No rows selected"
                    return
                end

                header_orient ||= :left
                rows_orient   ||= :left
                indent        ||= 2
                cellspace     ||= 1

                # pagebreak_after n-rows (without counting header or split-lines)
                # yield block with output as param after each pagebreak (not at the end)

                col_lengths = (0...(header.size)).collect do |colnr|
                    [
                        (0...rows.size).collect { |rownr|
                        value = rows[rownr][colnr]
                        coerce(value).size
                    }.max,
                        header[colnr].size
                    ].max
                end

                indent = " " * indent

                split_line = indent + "+"
                col_lengths.each {|col| split_line << "-" * (col+cellspace*2) + "+" }

                cellspace = " " * cellspace

                output_row = proc {|row, orient|
                    output << indent + "|"
                    row.each_with_index {|c,i|
                        output << cellspace

                        str = coerce(c)

                        output << case orient
                        when :left then   str.ljust(col_lengths[i])
                        when :right then  str.rjust(col_lengths[i])
                        when :center then str.center(col_lengths[i])
                        end 
                        output << cellspace
                        output << "|"
                    }
                    output << "\n" 
                } 

                rownr = 0

                loop do 
                    output << split_line + "\n"
                    output_row.call(header, header_orient)
                    output << split_line + "\n"
                    if pagebreak_after.nil?
                        rows.each {|ar| output_row.call(ar, rows_orient)}
                        output << split_line + "\n"
                        break
                    end      

                    rows[rownr,pagebreak_after].each {|ar| output_row.call(ar, rows_orient)}
                    output << split_line + "\n"

                    rownr += pagebreak_after

                    break if rownr >= rows.size

                    yield output if block_given?
                end

            end
        end # module TableFormatter
    end
end

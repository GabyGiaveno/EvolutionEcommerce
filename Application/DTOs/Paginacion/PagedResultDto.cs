using System;
using System.Collections.Generic;

namespace Application.DTOs.Paginacion
{
    public class PagedResultDto<T>
    {
        public IReadOnlyList<T> Items { get; }
        public int Page { get; }
        public int PageSize { get; }
        public int TotalCount { get; }
        public int TotalPages { get; }
        public bool HasPrevious => Page > 1;
        public bool HasNext => Page < TotalPages;

        public PagedResultDto(IReadOnlyList<T> items, int totalCount, int page, int pageSize)
        {
            Items = items ?? new List<T>();
            TotalCount = totalCount < 0 ? 0 : totalCount;
            Page = page < 1 ? 1 : page;
            PageSize = pageSize < 1 ? 1 : pageSize;
            TotalPages = PageSize == 0 ? 0 : (int)Math.Ceiling(TotalCount / (double)PageSize);
        }
    }
}


using Application.DTOs.Dlcs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces
{
    public interface IDlcServicio
    {
        Task<DlcRespuestaDto> CreateDlcAsync(DlcsCrearDto dlcDto);
    }
}
